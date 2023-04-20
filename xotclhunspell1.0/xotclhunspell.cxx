/*
 * Copyright 2006 by Artur Trzewik
 * All rights reserved
 *   
 *  This file is part of hunspelltcl Tcl extension

   Hunspelltcl Extension is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   Hunspelltcl is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  
*/

#include <stdio.h>
#include <tcl.h>
#include <hunspell.hxx>
#include <fcntl.h>
#include <stdlib.h>
#include <xotcl.h>

#if (TCL_MAJOR_VERSION==8 && TCL_MINOR_VERSION<1)
# define TclObjStr(obj) Tcl_GetStringFromObj(obj, ((int*)NULL))
#else
# define TclObjStr(obj) Tcl_GetString(obj)
#endif


typedef struct hunspell_s {
  Hunspell *hunspell;
  Tcl_Encoding encoding;
} hunspell_t;


static int
XOTclHunspellOpenMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  hunspell_t *hunspell;
  XOTcl_Object* obj = (XOTcl_Object*) cd;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 3)
    return XOTclObjErrArgCnt(in, obj->cmdName, "open affix_file directory_file");

  /* name not in hashtab - create new hunspell */
  if (XOTclGetObjClientData(obj))
    return XOTclVarErrMsg(in, "Called open on '", TclObjStr(obj->cmdName),
			  "', but open database was not closed before.", 0);

  hunspell = (hunspell_t*) ckalloc (sizeof(hunspell_t));
  
  hunspell->hunspell = new Hunspell(TclObjStr(objv[1]),TclObjStr(objv[2]));
  hunspell->encoding = NULL;

  XOTclSetObjClientData(obj, (ClientData) hunspell);
  return TCL_OK;
}

static int
XOTclHunspellCloseMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  hunspell_t *hunspell;
  XOTcl_Object* obj = (XOTcl_Object *) cd;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 1)
    return XOTclObjErrArgCnt(in, obj->cmdName, "close");
    
  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell)
    return XOTclVarErrMsg(in, "Called close on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  if (hunspell->encoding!=NULL)
      Tcl_FreeEncoding(hunspell->encoding);
  delete hunspell->hunspell;
  ckfree ((char*)hunspell);
  XOTclSetObjClientData(obj, 0);
  return TCL_OK;
}

static int
XOTclHunspellEncodingMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  hunspell_t *hunspell;
  char *encodingname;
  Tcl_Encoding encoding;
  XOTcl_Object* obj = (XOTcl_Object *) cd;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc < 1 || objc>2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "encoding ?encoding?");
    
  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called close on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  if (objc==1) {
     Tcl_SetObjResult(in, Tcl_NewStringObj(Tcl_GetEncodingName(hunspell->encoding),-1));
  } else {
     encodingname = Tcl_GetStringFromObj(objv[1],NULL);
     encoding = Tcl_GetEncoding(in, encodingname);
     if (encoding == NULL)
          return TCL_ERROR;
     if (hunspell->encoding!=NULL)
          Tcl_FreeEncoding(hunspell->encoding);
      hunspell->encoding = encoding;
  }
  return TCL_OK;
}

static int
XOTclHunspellGetDicEncodingMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  hunspell_t *hunspell;
  XOTcl_Object* obj = (XOTcl_Object *) cd;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 1)
    return XOTclObjErrArgCnt(in, obj->cmdName, "getDicEncoding");
    
  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called close on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_SetObjResult(in, Tcl_NewStringObj(hunspell->hunspell->get_dic_encoding(),-1));
  return TCL_OK;
}

static int
XOTclHunspellSpellMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *) cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "spell word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called names on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  res = Tcl_GetObjResult(in);
  Tcl_SetBooleanObj(res,hunspell->hunspell->spell(Tcl_DStringValue(&word)));
  Tcl_DStringFree(&word);
  return TCL_OK;
}

static int
XOTclHunspellPutWordMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *) cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "putWord word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called names on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  res = Tcl_GetObjResult(in);
  Tcl_SetIntObj(res,hunspell->hunspell->put_word(Tcl_DStringValue(&word)));
  Tcl_DStringFree(&word);
  return TCL_OK;
}

static int
XOTclHunspellPutWordSuffixMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *) cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word,word2;
  int length,length2;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 3)
    return XOTclObjErrArgCnt(in, obj->cmdName, "putWordSuffix word suffix");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called names on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[2], &length2), -1, &word2);
  res = Tcl_GetObjResult(in);
  Tcl_SetIntObj(res,hunspell->hunspell->put_word_suffix(Tcl_DStringValue(&word),Tcl_DStringValue(&word2)));
  Tcl_DStringFree(&word);
  Tcl_DStringFree(&word2);
  return TCL_OK;
}

static int
XOTclHunspellPutWordPatternMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *) cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word,word2;
  int length,length2;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc != 3)
    return XOTclObjErrArgCnt(in, obj->cmdName, "putWordPattern word pattern");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called names on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[2], &length2), -1, &word2);
  res = Tcl_GetObjResult(in);
  Tcl_SetIntObj(res,hunspell->hunspell->put_word_pattern(Tcl_DStringValue(&word),Tcl_DStringValue(&word2)));
  Tcl_DStringFree(&word);
  Tcl_DStringFree(&word2);
  return TCL_OK;
}

static int
XOTclHunspellSuggestMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *)cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;
  int sugcount;
  char **sugestions;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc!=2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "suggest word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called set on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  res = Tcl_GetObjResult(in);
  sugcount = hunspell->hunspell->suggest(&sugestions,Tcl_DStringValue(&word));
  Tcl_DStringFree(&word);
  if (sugcount==0) {
     return TCL_OK;
  }
  for (int i=0;i<sugcount;i++) {
    Tcl_ExternalToUtfDString(hunspell->encoding, sugestions[i], strlen(sugestions[i]), &word);
    Tcl_ListObjAppendElement(in,res,Tcl_NewStringObj(Tcl_DStringValue(&word), Tcl_DStringLength(&word)));
    Tcl_DStringFree(&word);
    free(sugestions[i]);
  }
  free(sugestions);
  return TCL_OK;
}

static int
XOTclHunspellStemMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *)cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;
  int sugcount;
  char **sugestions;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc!=2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "stem word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called set on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  res = Tcl_GetObjResult(in);
  sugcount = hunspell->hunspell->stem(&sugestions,Tcl_DStringValue(&word));
  Tcl_DStringFree(&word);
  if (sugcount==0) {
     return TCL_OK;
  }
  for (int i=0;i<sugcount;i++) {
    Tcl_ExternalToUtfDString(hunspell->encoding, sugestions[i], strlen(sugestions[i]), &word);
    Tcl_ListObjAppendElement(in,res,Tcl_NewStringObj(Tcl_DStringValue(&word), Tcl_DStringLength(&word)));
    Tcl_DStringFree(&word);
    free(sugestions[i]);
  }
  free(sugestions);
  return TCL_OK;
}

/*
static int
XOTclHunspellAnalyzeMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *)cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;
  int sugcount;
  char **sugestions;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc!=2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "stem word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called set on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }
  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), length, &word);
  res = Tcl_GetObjResult(in);
  // Unknown convention for paramters
  sugcount = hunspell->hunspell->analyze(&sugestions,Tcl_DStringValue(&word));
  Tcl_DStringFree(&word);
  for (int i=0;i<sugcount;i++) {
    Tcl_ExternalToUtfDString(hunspell->encoding, sugestions[i], strlen(sugestions[i]), &word);
    Tcl_ListObjAppendElement(in,res,Tcl_NewStringObj(Tcl_DStringValue(&word), Tcl_DStringLength(&word)));
    Tcl_DStringFree(&word);
    free(sugestions[i]);
  }
  free(sugestions);
  return TCL_OK;
}
*/

static int
XOTclHunspellMorphMethod(ClientData cd, Tcl_Interp* in, int objc, Tcl_Obj* CONST objv[]) {
  XOTcl_Object* obj = (XOTcl_Object *)cd;
  hunspell_t *hunspell;
  Tcl_Obj *res;
  Tcl_DString word;
  int length;
  char *morph;

  if (!obj) return XOTclObjErrType(in, obj->cmdName, "Object");
  if (objc!=2)
    return XOTclObjErrArgCnt(in, obj->cmdName, "morph word");

  hunspell = (hunspell_t*) XOTclGetObjClientData(obj);
  if (!hunspell) {
    return XOTclVarErrMsg(in, "Called set on '", TclObjStr(obj->cmdName),
			  "', but database was not opened yet.", 0);
  }

  Tcl_UtfToExternalDString(hunspell->encoding, Tcl_GetStringFromObj(objv[1], &length), -1, &word);
  morph = hunspell->hunspell->morph(Tcl_DStringValue(&word));
  Tcl_DStringFree(&word);
  if (!morph) {
    return TCL_OK;
  }
  Tcl_ExternalToUtfDString(hunspell->encoding, morph, strlen(morph), &word);
  res = Tcl_GetObjResult(in);
  Tcl_SetStringObj(res,Tcl_DStringValue(&word), Tcl_DStringLength(&word));
  Tcl_DStringFree(&word);
  free(morph);
  return TCL_OK;
}


/*
 * XotclHunspell_Init
 * register commands, init data structures
 */

extern "C" {
#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Xotclhunspell_Init(Tcl_Interp *interp);
}

extern int 
Xotclhunspell_Init(Tcl_Interp * in) {
  XOTcl_Class* cl;
  int result;

    if (Tcl_InitStubs(in, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    if (Xotcl_InitStubs(in, "1.1", 0) == NULL) {
        return TCL_ERROR;
    }
    if (Tcl_PkgRequire(in, "Tcl", TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    Tcl_PkgProvide(in, "xotcl::hunspell", PACKAGE_VERSION);

    if (Tcl_PkgRequire(in, "XOTcl", "1.3", 0) == NULL) {
        return TCL_ERROR;
    }
    result = Tcl_VarEval (in,"::xotcl::Class Hunspell",(char *) NULL);
    if (result != TCL_OK)
      return result;
    result = Tcl_VarEval (in,"Hunspell instproc destroy {} { catch {my close}; next}",(char *) NULL);
    if (result != TCL_OK)
      return result;

    cl = XOTclGetClass(in, "Hunspell");
    XOTclAddIMethod(in, cl, "open", XOTclHunspellOpenMethod, 0, 0);
    XOTclAddIMethod(in, cl, "close", XOTclHunspellCloseMethod, 0, 0);
    XOTclAddIMethod(in, cl, "spell", XOTclHunspellSpellMethod, 0, 0);
    XOTclAddIMethod(in, cl, "suggest", XOTclHunspellSuggestMethod, 0, 0);
    XOTclAddIMethod(in, cl, "encoding", XOTclHunspellEncodingMethod, 0, 0);
    XOTclAddIMethod(in, cl, "getDicEncoding", XOTclHunspellGetDicEncodingMethod, 0, 0);
    XOTclAddIMethod(in, cl, "putWord", XOTclHunspellPutWordMethod, 0, 0);
    XOTclAddIMethod(in, cl, "putWordSuffix", XOTclHunspellPutWordSuffixMethod, 0, 0);
    XOTclAddIMethod(in, cl, "putWordPattern", XOTclHunspellPutWordPatternMethod, 0, 0);
    XOTclAddIMethod(in, cl, "stem", XOTclHunspellStemMethod, 0, 0);
    XOTclAddIMethod(in, cl, "morph", XOTclHunspellMorphMethod, 0, 0);
    // XOTclAddIMethod(in, cl, "analyze", XOTclHunspellAnalyzeMethod, 0, 0);

    Tcl_SetIntObj(Tcl_GetObjResult(in), 1);
       
    return TCL_OK;
}

extern "C" {
#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Xotclhunspell_SafeInit(Tcl_Interp *interp);
}

extern
int Xotclhunspell_SafeInit(Tcl_Interp *interp)
{
    return Xotclhunspell_Init(interp);
}
