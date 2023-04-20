/*
 * Tcl Interface to fsa tool from 
 * http://www.eti.pg.gda.pl/katedry/kiw/pracownicy/Jan.Daciuk/personal/fsa.html
 * Artur Trzewik - All rights reserver 2007
 */


#include "tcl.h"
#include "../unix/fsa.h"
#include "../unix/common.h"
#include "../unix/morph.h"

typedef struct FsatclState { 
  morph_fsa *morph_dict;
  Tcl_Encoding encoding;
} FsatclState;

static int Fsamorph_morph(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  FsatclState *statePtr = (FsatclState *)clientData;
  Tcl_Obj *res;
  Tcl_DString word;
  char *stam;
  int length;
  if (!statePtr->morph_dict) {
	  Tcl_SetObjResult(interp, Tcl_NewStringObj("fsa ist not initialised",-1));
	  return TCL_ERROR;
  }
  if (objc != 2) {
      Tcl_WrongNumArgs(interp, 1, objv, "expect word to stam");
      return TCL_ERROR;
  }
  Tcl_UtfToExternalDString(statePtr->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  if (statePtr->morph_dict->morph_word(Tcl_DStringValue(&word))) {
    Tcl_DStringFree(&word);
	res = Tcl_GetObjResult(interp);
	for (statePtr->morph_dict->replacements.reset(); 
			statePtr->morph_dict->replacements.item(); 
			statePtr->morph_dict->replacements.next()) {
		stam = statePtr->morph_dict->replacements.item();
        // Tcl_ListObjAppendElement(interp,res,Tcl_NewStringObj(stam,-1));
		Tcl_ExternalToUtfDString(statePtr->encoding, stam, strlen(stam), &word);
		Tcl_ListObjAppendElement(interp,res,Tcl_NewStringObj(Tcl_DStringValue(&word), Tcl_DStringLength(&word)));
		Tcl_DStringFree(&word);
	}
	statePtr->morph_dict->replacements.empty_list();
  } else {
     Tcl_DStringFree(&word);
  }
  return TCL_OK;
}
static int Fsamorph_init(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  word_list	dict;
  char *encodingname;

  FsatclState *statePtr = (FsatclState *)clientData;
  if (objc < 1 || objc>3) {
	  Tcl_WrongNumArgs(interp, 1, objv, "expect: dictionary_file ?encoding");
      return TCL_ERROR;
  }
  if (statePtr->morph_dict) {
	  delete statePtr->morph_dict;
	  statePtr->morph_dict = 0;
  }
  if (statePtr->encoding) {
      Tcl_FreeEncoding(statePtr->encoding);
	  statePtr->encoding = 0;
  }

  if (objc==3) {	
  	 encodingname = Tcl_GetStringFromObj(objv[2],NULL);
     statePtr->encoding = Tcl_GetEncoding(interp, encodingname);
     if (statePtr->encoding == NULL)
          return TCL_ERROR;
  } 

  dict.insert(Tcl_GetStringFromObj(objv[1],0));
  // hasInfixes=1, hasPrefixes=1
  statePtr->morph_dict = new morph_fsa(FALSE,1,1,&dict,NULL);

  return TCL_OK;
}
static int Fsamorph_close(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  FsatclState *statePtr = (FsatclState *)clientData;
  if (statePtr->morph_dict) {
	  delete statePtr->morph_dict;
	  statePtr->morph_dict = 0;
  }
  if (statePtr->encoding) {
      Tcl_FreeEncoding(statePtr->encoding);
	  statePtr->encoding = 0;
  }
  return TCL_OK;
}

extern "C" {
#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Fsatcl_Init(Tcl_Interp *interp);
}
extern int Fsatcl_Init(Tcl_Interp *interp)
{
  FsatclState *statePtr;
 
  if (Tcl_InitStubs(interp, "8.1", 0) == NULL)
    return TCL_ERROR;
  if (Tcl_PkgRequire(interp, "Tcl", "8.1", 0) == NULL)
    return TCL_ERROR;
  if (Tcl_PkgProvide(interp, "fsatcl" , PACKAGE_VERSION) != TCL_OK)
    return TCL_ERROR;
  /*

   * Initialize the new Tcl commands.
   * Deleting any command will close all connections.
   */
   statePtr = (FsatclState*)Tcl_Alloc(sizeof(FsatclState));
   statePtr->morph_dict = 0;
   statePtr->encoding = 0;

   Tcl_CreateObjCommand(interp,"::fsa::morph",Fsamorph_morph,(ClientData)statePtr, NULL);
   Tcl_CreateObjCommand(interp,"::fsa::init", Fsamorph_init,(ClientData)statePtr, NULL);
   Tcl_CreateObjCommand(interp,"::fsa::close", Fsamorph_close,(ClientData)statePtr, NULL);
  
   return TCL_OK;
}

extern "C" {
#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Fsatcl_SafeInit(Tcl_Interp *interp);
}
int Fsatcl_SafeInit(Tcl_Interp *interp)
{
  return Fsatcl_Init(interp);
}
