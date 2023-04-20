/*
 * Tcl Interface to link parser 
 * 
 * Artur Trzewik - All rights reserver 2007
 */

#ifndef PACKAGE_VERSION
#define PACKAGE_VERSION "1.0"
#endif

#include "tcl.h"
#include "../unix/link-includes.h"

typedef struct LinkparserState { 
  int initialized;
  Dictionary    dict;
  Parse_Options opts;
} LinkparserState;

/*

Structure

{
   {list of words}

}

*/
static int Linkparser_parse(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  LinkparserState *statePtr = (LinkparserState *)clientData;
  Tcl_Obj *list,*res;
  // Tcl_DString word;
  Sentence      sent;
  Linkage       linkage;
  int length,num_linkages,i,N_links,link;
  
  if (statePtr->initialized==0) {
	  Tcl_SetObjResult(interp, Tcl_NewStringObj("linkparser ist not initialised",-1));
	  return TCL_ERROR;
  }
  if (objc != 2) {
      Tcl_WrongNumArgs(interp, 1, objv, "expect word to stam");
      return TCL_ERROR;
  }
  sent = sentence_create(Tcl_GetStringFromObj(objv[1], &length), statePtr->dict);
  res = Tcl_GetObjResult(interp);

  parse_options_set_min_null_count(statePtr->opts, 0);
  parse_options_set_max_null_count(statePtr->opts, 0);
  parse_options_reset_resources(statePtr->opts);

  num_linkages = sentence_parse(sent, statePtr->opts);

  if (num_linkages == 0) {
	 if (parse_options_get_allow_null(statePtr->opts)) {
		parse_options_set_min_null_count(statePtr->opts, 1);
		parse_options_set_max_null_count(statePtr->opts, sentence_length(sent));
		num_linkages = sentence_parse(sent, statePtr->opts);
	 }
  }

  if (num_linkages > 0) {
	    linkage = linkage_create(0, sent, statePtr->opts);
	    // No sublinkages needed
            linkage_compute_union(linkage);
		length = sentence_length(sent);
		// List of words
		list = Tcl_NewListObj(0,NULL);
		for (i=0;i<length;i++) {
			Tcl_ListObjAppendElement(interp,list,Tcl_NewStringObj(sentence_get_word(sent,i), -1));
		}
		Tcl_ListObjAppendElement(interp,res,list);

		// List of tagged words
		length = linkage_get_num_words(linkage);
		list = Tcl_NewListObj(0,NULL);
		for (i=0;i<length;i++) {
			Tcl_ListObjAppendElement(interp,list,Tcl_NewStringObj(linkage_get_word(linkage,i), -1));
		}
		Tcl_ListObjAppendElement(interp,res,list);

		N_links = linkage_get_num_links(linkage);

		for (link=0; link<N_links; link++) {
			if (linkage_get_link_lword(linkage, link) == -1) continue;
			list = Tcl_NewListObj(0,NULL);

			Tcl_ListObjAppendElement(interp,list,Tcl_NewIntObj(linkage_get_link_lword(linkage,link)));
			Tcl_ListObjAppendElement(interp,list,Tcl_NewStringObj(linkage_get_link_label(linkage,link),-1));
			Tcl_ListObjAppendElement(interp,list,Tcl_NewIntObj(linkage_get_link_rword(linkage,link)));

			Tcl_ListObjAppendElement(interp,res,list);
		}

	    linkage_delete(linkage);
  } else {
    sentence_delete(sent);
	if (parse_options_timer_expired(statePtr->opts)) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj("TIME_EXPIRED",-1));
	} else if (parse_options_memory_exhausted(statePtr->opts)) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj("MEMORY_EXHAUSTED",-1));
	} else if (parse_options_resources_exhausted(statePtr->opts)) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj("RESOURES_EXHAUSTED",-1));
	}
	parse_options_reset_resources(statePtr->opts);
	return TCL_ERROR;
  }

  sentence_delete(sent);
  return TCL_OK;
}
static int Linkparser_init(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  LinkparserState *statePtr = (LinkparserState *)clientData;
  int num;
  if (objc > 3) {
	  Tcl_WrongNumArgs(interp, 1, objv, "expect: ?max_time? ?max_memory?");
      return TCL_ERROR;
  }

  if (statePtr->initialized!=0) {
	  statePtr->initialized = 0;
	  dictionary_delete(statePtr->dict);
	  parse_options_delete(statePtr->opts);
  }

  statePtr->opts  = parse_options_create();
  parse_options_set_linkage_limit(statePtr->opts,1000);
  parse_options_set_islands_ok(statePtr->opts,TRUE);
  parse_options_set_panic_mode(statePtr->opts, TRUE);
  parse_options_set_short_length(statePtr->opts, 10);

  if (objc > 1) {
		if (Tcl_GetIntFromObj(interp,objv[1],&num)== TCL_OK) {
			parse_options_set_max_parse_time(statePtr->opts, num);
		} else {
			return TCL_ERROR;
		}
  }
  if (objc > 2) {
		if (Tcl_GetIntFromObj(interp,objv[2],&num)== TCL_OK) {
			parse_options_set_max_memory(statePtr->opts, num);
		} else {
			return TCL_ERROR;
		}
  }
  statePtr->dict  = dictionary_create("4.0.dict", "4.0.knowledge", NULL, "4.0.affix");
  if (statePtr->dict==NULL) {
      Tcl_SetObjResult(interp, Tcl_NewStringObj("Dictionay could not be intialized",-1));
      parse_options_delete(statePtr->opts);
      return TCL_ERROR;
  }
  statePtr->initialized = 1;

  return TCL_OK;
}
static int Linkparser_close(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  LinkparserState *statePtr = (LinkparserState *)clientData;
  if (statePtr->initialized!=0) {
	  statePtr->initialized = 0;
	  dictionary_delete(statePtr->dict);
	  parse_options_delete(statePtr->opts);
  }
  return TCL_OK;
}

#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Tcllinkparser_Init(Tcl_Interp *interp);
extern int Tcllinkparser_Init(Tcl_Interp *interp)
{
  LinkparserState *statePtr;
 
  if (Tcl_InitStubs(interp, "8.1", 0) == NULL)
    return TCL_ERROR;
  if (Tcl_PkgRequire(interp, "Tcl", "8.1", 0) == NULL)
    return TCL_ERROR;
  if (Tcl_PkgProvide(interp, "tcllinkparser" , PACKAGE_VERSION) != TCL_OK)
    return TCL_ERROR;

  /*
   * Initialize the new Tcl commands.
   * Deleting any command will close all connections.
   */
   statePtr = (LinkparserState*)Tcl_Alloc(sizeof(LinkparserState));
   statePtr->initialized=0;

   Tcl_CreateObjCommand(interp,"::linkparser::parse",Linkparser_parse,(ClientData)statePtr, NULL);
   Tcl_CreateObjCommand(interp,"::linkparser::init", Linkparser_init,(ClientData)statePtr, NULL);
   Tcl_CreateObjCommand(interp,"::linkparser::close", Linkparser_close,(ClientData)statePtr, NULL);
  
   return TCL_OK;
}

#ifdef _WINDOWS
__declspec( dllexport )
#endif
int Tcllinkparser_SafeInit(Tcl_Interp *interp);
extern int Tcllinkparser_SafeInit(Tcl_Interp *interp)
{
  return Tcllinkparser_Init(interp);
}
