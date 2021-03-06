;;; -*- Mode: Lisp; Package: STELLA; Syntax: COMMON-LISP; Base: 10 -*-

;;; startup-system.lisp

#|
 +---------------------------- BEGIN LICENSE BLOCK ---------------------------+
 |                                                                            |
 | Version: MPL 1.1/GPL 2.0/LGPL 2.1                                          |
 |                                                                            |
 | The contents of this file are subject to the Mozilla Public License        |
 | Version 1.1 (the "License"); you may not use this file except in           |
 | compliance with the License. You may obtain a copy of the License at       |
 | http://www.mozilla.org/MPL/                                                |
 |                                                                            |
 | Software distributed under the License is distributed on an "AS IS" basis, |
 | WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License   |
 | for the specific language governing rights and limitations under the       |
 | License.                                                                   |
 |                                                                            |
 | The Original Code is the PowerLoom KR&R System.                            |
 |                                                                            |
 | The Initial Developer of the Original Code is                              |
 | UNIVERSITY OF SOUTHERN CALIFORNIA, INFORMATION SCIENCES INSTITUTE          |
 | 4676 Admiralty Way, Marina Del Rey, California 90292, U.S.A.               |
 |                                                                            |
 | Portions created by the Initial Developer are Copyright (C) 1997-2014      |
 | the Initial Developer. All Rights Reserved.                                |
 |                                                                            |
 | Contributor(s):                                                            |
 |                                                                            |
 | Alternatively, the contents of this file may be used under the terms of    |
 | either the GNU General Public License Version 2 or later (the "GPL"), or   |
 | the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),   |
 | in which case the provisions of the GPL or the LGPL are applicable instead |
 | of those above. If you wish to allow use of your version of this file only |
 | under the terms of either the GPL or the LGPL, and not to allow others to  |
 | use your version of this file under the terms of the MPL, indicate your    |
 | decision by deleting the provisions above and replace them with the notice |
 | and other provisions required by the GPL or the LGPL. If you do not delete |
 | the provisions above, a recipient may use your version of this file under  |
 | the terms of any one of the MPL, the GPL or the LGPL.                      |
 |                                                                            |
 +----------------------------- END LICENSE BLOCK ----------------------------+
|#

(CL:IN-PACKAGE "STELLA")

;;; Auxiliary variables:

(CL:DEFVAR SYM-STARTUP-SYSTEM-LOGIC-STARTUP-LOGIC-SYSTEM NULL)
(CL:DEFVAR SYM-STARTUP-SYSTEM-STELLA-METHOD-STARTUP-CLASSNAME NULL)

;;; Forward declarations:

(CL:DECLAIM (CL:SPECIAL *BOOTSTRAP-LOCK* *STARTUP-TIME-PHASE* *MODULE*))

(CL:DEFUN STARTUP-LOGIC-SYSTEM ()
  (WITH-PROCESS-LOCK *BOOTSTRAP-LOCK*
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 0)
    (CL:WHEN (CL:NOT (SYSTEM-STARTED-UP? "stella" "/STELLA"))
     (STARTUP-STELLA-SYSTEM)))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 1)
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/LOGIC"
     "(:LISP-PACKAGE \"STELLA\" :CPP-PACKAGE \"logic\" :JAVA-PACKAGE \"edu.isi.powerloom.logic\" :CLEARABLE? FALSE :CODE-ONLY? TRUE)")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/PL-KERNEL-KB"
     "(:DOCUMENTATION \"Defines foundation classes and relations for PowerLoom.\" :CPP-PACKAGE \"pl_kernel_kb\" :JAVA-PACKAGE \"edu.isi.powerloom.pl_kernel_kb\" :USES (\"LOGIC\" \"STELLA\") :SHADOW (COLLECTION SET RELATION FUNCTION CLASS LIST VALUE ARITY INVERSE NAME QUANTITY FLOOR CEILING LOG LOG10 EXP EXPT) :NICKNAME \"PL-KERNEL\" :PROTECT-SURROGATES? TRUE)")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/PL-KERNEL-KB/PL-USER"
     "(:DOCUMENTATION \"The default module for PowerLoom users.  It does not
contain any local declarations or axioms, but it includes other modules
needed to call PowerLoom functions.\" :INCLUDES (\"PL-KERNEL\") :USES (\"LOGIC\" \"STELLA\"))")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/PL-ANONYMOUS"
     "(:DOCUMENTATION \"Holds names of system-generated anonymous objects such as prototypes.
Users should never allocate any names in this module.\" :CASE-SENSITIVE? TRUE :USES ())")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/PL-KERNEL-KB/LOOM-API"
     "(:DOCUMENTATION \"Defines a Loom API for PowerLoom.\" :LISP-PACKAGE \"LOOM-API\" :INCLUDES \"PL-KERNEL\" :USES (\"LOGIC\" \"STELLA\") :SHADOW (NAMED?) :PROTECT-SURROGATES? TRUE)")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE
     "/PL-KERNEL-KB/KIF-FRAME-ONTOLOGY"
     "(:DOCUMENTATION \"Defines KIF-compatible frame predicates following
Ontolingua conventions.\" :USES (\"LOGIC\" \"STELLA\"))")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE
     "/PL-KERNEL-KB/CYC-FRAME-ONTOLOGY"
     "(:DOCUMENTATION \"Defines Cyc-compatible frame predicates.\" :USES (\"LOGIC\" \"STELLA\"))")
    (DEFINE-MODULE-FROM-STRINGIFIED-SOURCE "/PLI"
     "(:DOCUMENTATION \"Defines the PowerLoom API.\" :USES (\"LOGIC\" \"STELLA\") :SHADOW (GET-OBJECT GET-RELATION GET-MODULE CHANGE-MODULE CLEAR-MODULE LOAD LOAD-IN-MODULE LOAD-STREAM LOAD-STREAM-IN-MODULE GET-RULES PRINT-RULES RUN-FORWARD-RULES SAVE-MODULE CREATE-OBJECT DESTROY-OBJECT REGISTER-SPECIALIST-FUNCTION REGISTER-COMPUTATION-FUNCTION ASSERT RETRACT CONCEIVE EVALUATE EVALUATE-STRING IS-TRUE IS-FALSE IS-UNKNOWN ASK RETRIEVE CREATE-ENUMERATED-SET RESET-POWERLOOM CLEAR-CACHES) :API? TRUE :LISP-PACKAGE \"PLI\" :CPP-PACKAGE \"pli\" :JAVA-PACKAGE \"edu.isi.powerloom\" :JAVA-CATCHALL-CLASS \"PLI\" :CODE-ONLY? TRUE)"))
   (CL:LET*
    ((*MODULE* (GET-STELLA-MODULE "/LOGIC" (> *STARTUP-TIME-PHASE* 1)))
     (*CONTEXT* *MODULE*))
    (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
    (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 2)
     (CL:SETQ SYM-STARTUP-SYSTEM-LOGIC-STARTUP-LOGIC-SYSTEM
      (INTERN-RIGID-SYMBOL-WRT-MODULE "STARTUP-LOGIC-SYSTEM" NULL 0))
     (CL:SETQ SYM-STARTUP-SYSTEM-STELLA-METHOD-STARTUP-CLASSNAME
      (INTERN-RIGID-SYMBOL-WRT-MODULE "METHOD-STARTUP-CLASSNAME"
       (GET-STELLA-MODULE "/STELLA" CL:T) 0)))
    (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 6) (FINALIZE-CLASSES))
    (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 7)
     (DEFINE-FUNCTION-OBJECT "STARTUP-LOGIC-SYSTEM"
      "(DEFUN STARTUP-LOGIC-SYSTEM () :PUBLIC? TRUE)"
      (CL:FUNCTION STARTUP-LOGIC-SYSTEM) NULL)
     (CL:LET*
      ((FUNCTION
        (LOOKUP-FUNCTION
         SYM-STARTUP-SYSTEM-LOGIC-STARTUP-LOGIC-SYSTEM)))
      (SET-DYNAMIC-SLOT-VALUE (%DYNAMIC-SLOTS FUNCTION)
       SYM-STARTUP-SYSTEM-STELLA-METHOD-STARTUP-CLASSNAME
       (WRAP-STRING "StartupLogicSystem") NULL-STRING-WRAPPER)))
    (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 8) (FINALIZE-SLOTS)
     (CLEANUP-UNFINALIZED-CLASSES))
    (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 9)
     (%IN-MODULE (COPY-CONS-TREE (WRAP-STRING "/LOGIC")))
     (CL:LET* ((PHASE NULL-INTEGER) (ITER-064 0) (UPPER-BOUND-065 9))
      (CL:DECLARE (CL:TYPE CL:FIXNUM PHASE ITER-064 UPPER-BOUND-065))
      (CL:LOOP WHILE (CL:<= ITER-064 UPPER-BOUND-065) DO
       (CL:SETQ PHASE ITER-064) (CL:SETQ *STARTUP-TIME-PHASE* PHASE)
       (STARTUP-LOGIC-MACROS) (STARTUP-SEQUENCE-INDICES)
       (STARTUP-KIF-IN) (STARTUP-PROPOSITIONS) (STARTUP-BACKLINKS)
       (STARTUP-PROPAGATE) (STARTUP-INFERENCE-CACHES)
       (STARTUP-DESCRIPTIONS) (STARTUP-NORMALIZE) (STARTUP-RULES)
       (STARTUP-QUERY) (STARTUP-PARTIAL-MATCH)
       (STARTUP-MACHINE-LEARNING) (STARTUP-RULE-INDUCTION)
       (STARTUP-NEURAL-NETWORK) (STARTUP-CASE-BASED)
       (STARTUP-GOAL-CACHES) (STARTUP-STRATEGIES)
       (STARTUP-JUSTIFICATIONS) (STARTUP-EXPLANATIONS) (STARTUP-WHYNOT)
       (STARTUP-KIF-OUT) (STARTUP-PRINT) (STARTUP-GENERATE)
       (STARTUP-SPECIALISTS) (STARTUP-SPECIALIZE) (STARTUP-OPTIMIZE)
       (STARTUP-CLASSIFY) (STARTUP-LOGIC-IN)
       (|/PL-KERNEL-KB/STARTUP-PL-KERNEL-KB|)
       (|/PL-KERNEL-KB/STARTUP-ARITHMETIC|) (STARTUP-FRAME-SUPPORT)
       (LOOM-API::STARTUP-LOOM-SUPPORT) (STARTUP-LOOM-TO-KIF)
       (STARTUP-API-SUPPORT) (PLI::STARTUP-PLI) (STARTUP-POWERLOOM)
       (STARTUP-TOOLS) (CL:SETQ ITER-064 (CL:1+ ITER-064))))
     (CL:SETQ *STARTUP-TIME-PHASE* 999)))))
