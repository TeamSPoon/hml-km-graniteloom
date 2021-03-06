;;; -*- Mode: Lisp; Package: STELLA; Syntax: COMMON-LISP; Base: 10 -*-

;;; java-translate-file.lisp

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
| The Original Code is the STELLA Programming Language.                      |
|                                                                            |
| The Initial Developer of the Original Code is                              |
| UNIVERSITY OF SOUTHERN CALIFORNIA, INFORMATION SCIENCES INSTITUTE          |
| 4676 Admiralty Way, Marina Del Rey, California 90292, U.S.A.               |
|                                                                            |
| Portions created by the Initial Developer are Copyright (C) 1996-2014      |
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
+---------------------------- END LICENSE BLOCK -----------------------------+
|#

(CL:IN-PACKAGE "STELLA")

;;; Auxiliary variables:

(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-COMMON-LISP NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-JAVA NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-JPTRANS NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-FUNCTION NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-MINIMIZE-JAVA-PREFIXES NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-CONSTRUCTOR? NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-NATIVE? NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-MACRO NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-PRINT-METHOD NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-TYPE NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-VERBATIM NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-CLASS NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-GLOBAL-VARIABLE NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-STARTUP-CLASSNAME NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-TWO-PASS? NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-FORCE-TRANSLATION? NULL)
(CL:DEFVAR KWD-JAVA-TRANSLATE-FILE-PRODUCTION-SETTINGS? NULL)
(CL:DEFVAR SYM-JAVA-TRANSLATE-FILE-STELLA-STARTUP-JAVA-TRANSLATE-FILE NULL)

;;; Forward declarations:

(CL:DECLAIM
 (CL:SPECIAL TRUE-WRAPPER *JAVA-INDENT-CHARS*
  *JAVA-STELLA-PACKAGE-MAPPING* *TRANSLATIONUNITS* NULL-STRING-WRAPPER
  FALSE-WRAPPER *CONTEXT* *STELLA-MODULE* *CURRENT-STELLA-FEATURES* EOL
  *TRANSLATIONVERBOSITYLEVEL* *CURRENT-STREAM* NIL *MODULE*
  *TRANSLATOROUTPUTLANGUAGE* STANDARD-OUTPUT))

;;; (DEFSPECIAL *CURRENT-JAVA-OUTPUT-CLASS* ...)

(CL:DEFVAR *CURRENT-JAVA-OUTPUT-CLASS* NULL
  "Holds the current Stella class being output in Java")

;;; (DEFUN CLT ...)

(CL:DEFUN CLT ()
  (CHANGE-MODULE "STELLA")
  (%SET-TRANSLATOR-OUTPUT-LANGUAGE KWD-JAVA-TRANSLATE-FILE-COMMON-LISP)
  :VOID)

;;; (DEFUN JT ...)

(CL:DEFUN JT ()
  (CHANGE-MODULE "STELLA")
  (%SET-TRANSLATOR-OUTPUT-LANGUAGE KWD-JAVA-TRANSLATE-FILE-JAVA)
  :VOID)

;;; (DEFUN JPTRANS ...)

(CL:DEFUN %JPTRANS (STATEMENT)
  "Translate `statement' to C++ and print the result."
  (CL:LET*
   ((*TRANSLATOROUTPUTLANGUAGE* *TRANSLATOROUTPUTLANGUAGE*)
    (*CURRENT-STREAM* STANDARD-OUTPUT))
   (CL:DECLARE
    (CL:SPECIAL *TRANSLATOROUTPUTLANGUAGE* *CURRENT-STREAM*))
   (%SET-TRANSLATOR-OUTPUT-LANGUAGE KWD-JAVA-TRANSLATE-FILE-JAVA)
   (INCREMENTALLY-TRANSLATE STATEMENT))
  :VOID)

(CL:DEFMACRO JPTRANS (CL:&WHOLE EXPRESSION CL:&REST IGNORE)
  "Translate `statement' to C++ and print the result."
  (CL:DECLARE (CL:IGNORE IGNORE))
  (CL:LET ((*IGNORETRANSLATIONERRORS?* FALSE))
   (CL-INCREMENTALLY-TRANSLATE EXPRESSION)))

(CL:SETF (CL:MACRO-FUNCTION (CL:QUOTE |/STELLA/JPTRANS|)) (CL:MACRO-FUNCTION (CL:QUOTE JPTRANS)))

;;; (DEFMETHOD (JAVA-MAKE-CODE-OUTPUT-FILE-NAME FILE-NAME) ...)

(CL:DEFMETHOD JAVA-MAKE-CODE-OUTPUT-FILE-NAME ((BAREFILE CL:STRING) DONTTRUNCATE?)
  (CL:IF DONTTRUNCATE?
   (CL:LET* ((*DONTTRUNCATEFILENAMES?* CL:T))
    (CL:DECLARE (CL:SPECIAL *DONTTRUNCATEFILENAMES?*))
    (CL:RETURN-FROM JAVA-MAKE-CODE-OUTPUT-FILE-NAME
     (MAKE-FILE-NAME-FROM-RELATIVE-PATH (WRAP-STRING BAREFILE)
      KWD-JAVA-TRANSLATE-FILE-JAVA)))
   (CL:RETURN-FROM JAVA-MAKE-CODE-OUTPUT-FILE-NAME
    (MAKE-FILE-NAME-FROM-RELATIVE-PATH (WRAP-STRING BAREFILE)
     KWD-JAVA-TRANSLATE-FILE-JAVA))))

;;; (DEFMETHOD (JAVA-MAKE-CODE-OUTPUT-FILE-NAME FILE-NAME) ...)

(CL:DEFMETHOD JAVA-MAKE-CODE-OUTPUT-FILE-NAME ((SOURCE CLASS) DONTTRUNCATE?)
  (CL:LET*
   ((BAREFILE
     (JAVA-TRANSLATE-CLASS-NAMESTRING
      (WRAP-STRING (CLASS-NAME SOURCE)))))
   (CL:RETURN-FROM JAVA-MAKE-CODE-OUTPUT-FILE-NAME
    (JAVA-MAKE-CODE-OUTPUT-FILE-NAME (%WRAPPER-VALUE BAREFILE)
     DONTTRUNCATE?))))

;;; (DEFUN (JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME FILE-NAME) ...)

(CL:DEFUN JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME (MODULE DONTTRUNCATE?)
  (CL:RETURN-FROM JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME
   (JAVA-MAKE-CODE-OUTPUT-FILE-NAME
    (JAVA-YIELD-FLOTSAM-CLASS-NAME MODULE) DONTTRUNCATE?)))

;;; (DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE ...)

(CL:DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE (GLOBALSHT FUNCTIONHT CODEMODULELIST)
  (CL:LET*
   ((FUNCTIONS NIL) (GLOBALS NIL) (FILENAME STELLA::NULL-STRING)
    (FLOTSAM-FILES NIL))
   (CL:LET* ((MODULE NULL) (ITER-000 CODEMODULELIST))
    (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-000 NIL)) DO
     (CL:SETQ MODULE (%%VALUE ITER-000))
     (CL:LET* ((*MODULE* MODULE) (*CONTEXT* *MODULE*))
      (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
      (CL:SETQ FILENAME
       (JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME MODULE CL:NIL))
      (CL:WHEN (MEMBER? FLOTSAM-FILES (WRAP-STRING FILENAME))
       (CL:WARN "Overwriting Flotsam file `~A'.  This is surely bad."
        FILENAME))
      (CL:SETQ FLOTSAM-FILES
       (CONS (WRAP-STRING FILENAME) FLOTSAM-FILES))
      (CL:SETQ GLOBALS (LOOKUP GLOBALSHT MODULE))
      (CL:WHEN (CL:EQ GLOBALS NULL) (CL:SETQ GLOBALS NIL))
      (CL:SETQ FUNCTIONS (LOOKUP FUNCTIONHT MODULE))
      (CL:WHEN (CL:EQ FUNCTIONS NULL) (CL:SETQ FUNCTIONS NIL))
      (JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE FILENAME MODULE
       NULL GLOBALS FUNCTIONS))
     (CL:SETQ ITER-000 (%%REST ITER-000)))))
  :VOID)

;;; (DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE ...)

(CL:DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE (CLASSOUTPUTFILE MODULE CLASSUNIT GLOBALS FUNCTIONS)
  (CL:LET* ((*CURRENT-JAVA-OUTPUT-CLASS* NULL))
   (CL:DECLARE (CL:SPECIAL *CURRENT-JAVA-OUTPUT-CLASS*))
   (CL:LET* ((TRANSLATION NIL) (CLASS NULL) (CLASSTRANSLATION NIL))
    (CL:LET* ((*MODULE* MODULE) (*CONTEXT* *MODULE*))
     (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
     (CL:LET* ((CLASSOUTPUTSTREAM NULL))
      (CL:UNWIND-PROTECT
       (CL:PROGN
        (CL:SETQ CLASSOUTPUTSTREAM (OPEN-OUTPUT-FILE CLASSOUTPUTFILE))
        (CL:WHEN (CL:NOT (CL:EQ CLASSUNIT NULL))
         (CL:SETQ *CURRENT-JAVA-OUTPUT-CLASS* (%THE-OBJECT CLASSUNIT))
         (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
          "Translating `" CLASS "'..." EOL)
         (CL:SETQ CLASSTRANSLATION
          (%%REST
           (JAVA-TRANSLATE-DEFINE-NATIVE-CLASS
            *CURRENT-JAVA-OUTPUT-CLASS*))))
        (CL:LET* ((*CURRENT-STREAM* CLASSOUTPUTSTREAM))
         (CL:DECLARE (CL:SPECIAL *CURRENT-STREAM*))
         (CL:WHEN (CL:>= *TRANSLATIONVERBOSITYLEVEL* 1)
          (CL:IF (CL:NOT (CL:EQ CLASSUNIT NULL))
           (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
            "    Writing `" CLASSOUTPUTFILE "' ..." EOL)
           (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT) "Writing `"
            CLASSOUTPUTFILE "'..." EOL)))
         (JAVA-OUTPUT-FILE-HEADER CLASSOUTPUTSTREAM
          (JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME MODULE CL:T))
         (CL:IF (CL:NOT (CL:EQ CLASSUNIT NULL))
          (JAVA-OUTPUT-CLASS-DECLARATION CLASSTRANSLATION)
          (%%PRINT-STREAM (%NATIVE-STREAM *CURRENT-STREAM*)
           "public class " (JAVA-YIELD-FLOTSAM-CLASS-NAME MODULE) " "))
         (%%PRINT-STREAM (%NATIVE-STREAM *CURRENT-STREAM*) "{" EOL)
         (JAVA-BUMP-INDENT)
         (CL:WHEN (CL:NOT (CL:EQ CLASSUNIT NULL))
          (JAVA-OUTPUT-CLASS-VARIABLE-DEFINITIONS
           (NTH CLASSTRANSLATION 6)))
         (CL:LET* ((GLOBAL NULL) (ITER-000 GLOBALS))
          (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-000 NIL)) DO
           (CL:SETQ GLOBAL (%%VALUE ITER-000))
           (CL:SETQ TRANSLATION (JAVA-TRANSLATE-UNIT GLOBAL))
           (JAVA-OUTPUT-GLOBAL-DEFINITION (%%REST TRANSLATION))
           (CL:SETF (%TRANSLATION GLOBAL) NULL)
           (CL:SETF (%CODE-REGISTER GLOBAL) NULL)
           (CL:SETQ ITER-000 (%%REST ITER-000))))
         (CL:WHEN (CL:NOT (CL:EQ CLASSUNIT NULL))
          (JAVA-OUTPUT-CLASS-CONSTRUCTORS (NTH CLASSTRANSLATION 7)
           (JAVA-YIELD-FLOTSAM-CLASS-NAME MODULE)
           (CL:AND (CL:NOT (CL:EQ *CURRENT-JAVA-OUTPUT-CLASS* NULL))
            (EXCEPTION-CLASS? *CURRENT-JAVA-OUTPUT-CLASS*)))
          (CL:LET*
           ((STATEMENT NULL) (ITER-001 (NTH CLASSTRANSLATION 8)))
           (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-001 NIL)) DO
            (CL:SETQ STATEMENT (%%VALUE ITER-001))
            (JAVA-OUTPUT-STATEMENT (JAVA-TRANSLATE-UNIT STATEMENT))
            (CL:SETF (%TRANSLATION STATEMENT) NULL)
            (CL:SETF (%CODE-REGISTER STATEMENT) NULL)
            (CL:SETQ ITER-001 (%%REST ITER-001)))))
         (CL:LET* ((FUNCTION NULL) (ITER-002 FUNCTIONS))
          (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-002 NIL)) DO
           (CL:SETQ FUNCTION (%%VALUE ITER-002))
           (JAVA-OUTPUT-METHOD (%%REST (JAVA-TRANSLATE-UNIT FUNCTION)))
           (CL:SETF (%TRANSLATION FUNCTION) NULL)
           (CL:SETF (%CODE-REGISTER FUNCTION) NULL)
           (CL:SETQ ITER-002 (%%REST ITER-002))))
         (JAVA-UNBUMP-INDENT)
         (%%PRINT-STREAM (%NATIVE-STREAM *CURRENT-STREAM*) "}" EOL)))
       (CL:WHEN (CL:NOT (CL:EQ CLASSOUTPUTSTREAM NULL))
        (FREE CLASSOUTPUTSTREAM)))))))
  :VOID)

;;; (DEFUN JAVA-OUTPUT-FILE-HEADER ...)

(CL:DEFUN JAVA-OUTPUT-FILE-HEADER (STREAM FILENAME)
  (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "//  -*- Mode: Java -*-" EOL
   "//" EOL)
  (CL:WHEN (CL:NOT (CL:EQ FILENAME STELLA::NULL-STRING))
   (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "// "
    (FILE-NAME-WITHOUT-DIRECTORY FILENAME) EOL EOL))
  (CL:LET*
   ((PACKAGE-NAME (JAVA-PACKAGE-PREFIX *MODULE* "."))
    (IMPORTED-PACKAGES NIL) (NAME STELLA::NULL-STRING))
   (CL:DECLARE (CL:TYPE CL:SIMPLE-STRING PACKAGE-NAME NAME))
   (OUTPUT-COPYRIGHT-HEADER STREAM)
   (CL:WHEN
    (CL:NOT
     (CL:OR (CL:EQ PACKAGE-NAME STELLA::NULL-STRING)
      (STRING-EQL? PACKAGE-NAME "")))
    (CL:SETQ PACKAGE-NAME
     (SUBSEQUENCE PACKAGE-NAME 0
      (CL:1- (CL:THE CL:FIXNUM (CL:LENGTH PACKAGE-NAME)))))
    (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "package " PACKAGE-NAME ";"
     EOL EOL))
   (CL:IF (CL:EQ *MODULE* *STELLA-MODULE*)
    (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "import "
     (JAVA-STELLA-PACKAGE) ".javalib.*;" EOL)
    (CL:PROGN
     (CL:WHEN
      (CL:AND (CL:EQ (GET-STELLA-CLASS "NATIVE" CL:NIL) NULL)
       (CL:NOT (INHERITED-CLASS-NAME-CONFLICTS? "NATIVE")))
      (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "import "
       (JAVA-STELLA-PACKAGE) ".javalib.Native;" EOL))
     (CL:WHEN
      (CL:AND
       (CL:EQ (GET-STELLA-CLASS "STELLA-SPECIAL-VARIABLE" CL:NIL) NULL)
       (CL:NOT
        (INHERITED-CLASS-NAME-CONFLICTS? "STELLA-SPECIAL-VARIABLE")))
      (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "import "
       (JAVA-STELLA-PACKAGE) ".javalib.StellaSpecialVariable;" EOL))))
   (CL:WHEN
    (MEMB? *CURRENT-STELLA-FEATURES*
     KWD-JAVA-TRANSLATE-FILE-MINIMIZE-JAVA-PREFIXES)
    (CL:LET*
     ((MODULE NULL) (ITER-000 (%THE-CONS-LIST (%USES *MODULE*))))
     (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-000 NIL)) DO
      (CL:SETQ MODULE (%%VALUE ITER-000))
      (CL:SETQ NAME (JAVA-PACKAGE-PREFIX MODULE "."))
      (CL:WHEN
       (CL:NOT
        (CL:OR (STRING-EQL? NAME PACKAGE-NAME)
         (MEMBER? IMPORTED-PACKAGES (WRAP-STRING NAME))))
       (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "import " NAME "*;" EOL)
       (CL:SETQ IMPORTED-PACKAGES
        (CONS (WRAP-STRING NAME) IMPORTED-PACKAGES)))
      (CL:SETQ ITER-000 (%%REST ITER-000))))
    (CL:LET* ((MODULE NULL) (ITER-001 (%ALL-SUPER-CONTEXTS *MODULE*)))
     (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-001 NIL)) DO
      (CL:SETQ MODULE (%%VALUE ITER-001))
      (CL:SETQ NAME (JAVA-PACKAGE-PREFIX MODULE "."))
      (CL:WHEN
       (CL:NOT
        (CL:OR (STRING-EQL? NAME PACKAGE-NAME)
         (MEMBER? IMPORTED-PACKAGES (WRAP-STRING NAME))))
       (%%PRINT-STREAM (%NATIVE-STREAM STREAM) "import " NAME "*;" EOL)
       (CL:SETQ IMPORTED-PACKAGES
        (CONS (WRAP-STRING NAME) IMPORTED-PACKAGES)))
      (CL:SETQ ITER-001 (%%REST ITER-001)))))
   (%%PRINT-STREAM (%NATIVE-STREAM STREAM) EOL))
  :VOID)

;;; (DEFUN JAVA-OUTPUT-CLASS-TO-FILE ...)

(CL:DEFUN JAVA-OUTPUT-CLASS-TO-FILE (CLASS)
  (CL:LET* ((*CURRENT-JAVA-OUTPUT-CLASS* CLASS))
   (CL:DECLARE (CL:SPECIAL *CURRENT-JAVA-OUTPUT-CLASS*))
   (CL:LET*
    ((*CONTEXT* (HOME-MODULE CLASS))
     (*MODULE* (%BASE-MODULE *CONTEXT*)))
    (CL:DECLARE (CL:SPECIAL *CONTEXT* *MODULE*))
    (CL:LET*
     ((CLASSOUTPUTFILE (JAVA-MAKE-CODE-OUTPUT-FILE-NAME CLASS CL:NIL))
      (TRANSLATION NIL))
     (CL:LET* ((CLASSOUTPUTSTREAM NULL))
      (CL:UNWIND-PROTECT
       (CL:PROGN
        (CL:SETQ CLASSOUTPUTSTREAM (OPEN-OUTPUT-FILE CLASSOUTPUTFILE))
        (CL:LET* ((*CURRENT-STREAM* CLASSOUTPUTSTREAM))
         (CL:DECLARE (CL:SPECIAL *CURRENT-STREAM*))
         (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
          "Translating `" CLASS "'..." EOL)
         (CL:SETQ TRANSLATION
          (JAVA-TRANSLATE-DEFINE-NATIVE-CLASS CLASS))
         (CL:WHEN (CL:>= *TRANSLATIONVERBOSITYLEVEL* 1)
          (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
           "    Writing `" CLASSOUTPUTFILE "'..." EOL))
         (JAVA-OUTPUT-FILE-HEADER CLASSOUTPUTSTREAM
          (JAVA-MAKE-CODE-OUTPUT-FILE-NAME CLASS CL:T))
         (JAVA-OUTPUT-CLASS (%%REST TRANSLATION)
          (EXCEPTION-CLASS? CLASS))))
       (CL:WHEN (CL:NOT (CL:EQ CLASSOUTPUTSTREAM NULL))
        (FREE CLASSOUTPUTSTREAM)))))))
  :VOID)

;;; (DEFUN JAVA-OUTPUT-CLASS-UNIT-TO-FILE ...)

(CL:DEFUN JAVA-OUTPUT-CLASS-UNIT-TO-FILE (CLASSUNIT)
  (JAVA-OUTPUT-CLASS-TO-FILE (%THE-OBJECT CLASSUNIT))
  :VOID)

;;; (DEFUN (JAVA-FLOTSAM-FUNCTION? BOOLEAN) ...)

(CL:DEFUN JAVA-FLOTSAM-FUNCTION? (METHOD)
  (CL:RETURN-FROM JAVA-FLOTSAM-FUNCTION?
   (CL:AND
    (CL:NOT
     (%WRAPPER-VALUE
      (DYNAMIC-SLOT-VALUE (%DYNAMIC-SLOTS METHOD)
       SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-CONSTRUCTOR?
       FALSE-WRAPPER)))
    (CL:NOT
     (%WRAPPER-VALUE
      (DYNAMIC-SLOT-VALUE (%DYNAMIC-SLOTS METHOD)
       SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-NATIVE? FALSE-WRAPPER)))
    (CL:NOT (METHOD-STARTUP-FUNCTION? METHOD))
    (CL:OR (ZERO-ARGUMENT-FUNCTION? METHOD)
     (JAVA-METHOD-OBJECT-DEFINED-ON-NATIVE-TYPE? METHOD)
     (JAVA-FUNCTION-IN-DIFFERENT-MODULE? METHOD)))))

;;; (DEFUN JAVA-OUTPUT-STARTUP-UNITS-TO-FILE ...)

(CL:DEFUN JAVA-OUTPUT-STARTUP-UNITS-TO-FILE (STARTUPHT KEYLIST)
  (CL:LET*
   ((CLASSOUTPUTFILE STELLA::NULL-STRING) (STARTUPFUNCTIONS NULL))
   (CL:LET* ((*CURRENT-STREAM* NULL))
    (CL:DECLARE (CL:SPECIAL *CURRENT-STREAM*))
    (CL:LET* ((CLASSNAME NULL) (ITER-000 KEYLIST))
     (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-000 NIL)) DO
      (CL:SETQ CLASSNAME (%%VALUE ITER-000))
      (CL:SETQ STARTUPFUNCTIONS
       (LOOKUP STARTUPHT (%WRAPPER-VALUE CLASSNAME)))
      (CL:WHEN
       (CL:AND (CL:NOT (CL:EQ STARTUPFUNCTIONS NULL))
        (CL:NOT (CL:EQ STARTUPFUNCTIONS NULL)))
       (CL:LET*
        ((*MODULE* (HOME-MODULE (%%VALUE STARTUPFUNCTIONS)))
         (*CONTEXT* *MODULE*))
        (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
        (CL:SETQ CLASSOUTPUTFILE
         (JAVA-MAKE-CODE-OUTPUT-FILE-NAME (%WRAPPER-VALUE CLASSNAME)
          CL:NIL))
        (CL:LET* ((CLASSOUTPUTSTREAM NULL))
         (CL:UNWIND-PROTECT
          (CL:PROGN
           (CL:SETQ CLASSOUTPUTSTREAM
            (OPEN-OUTPUT-FILE CLASSOUTPUTFILE))
           (CL:SETQ *CURRENT-STREAM* CLASSOUTPUTSTREAM)
           (CL:WHEN (CL:>= *TRANSLATIONVERBOSITYLEVEL* 1)
            (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
             "Writing `" CLASSOUTPUTFILE "'..." EOL))
           (JAVA-OUTPUT-FILE-HEADER CLASSOUTPUTSTREAM
            (JAVA-MAKE-CODE-OUTPUT-FILE-NAME (%WRAPPER-VALUE CLASSNAME)
             CL:T))
           (%%PRINT-STREAM (%NATIVE-STREAM *CURRENT-STREAM*)
            "public class " (%WRAPPER-VALUE CLASSNAME) " {" EOL)
           (JAVA-BUMP-INDENT)
           (CL:LET* ((FUNCTION NULL) (ITER-001 STARTUPFUNCTIONS))
            (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-001 NIL)) DO
             (CL:SETQ FUNCTION (%%VALUE ITER-001))
             (JAVA-OUTPUT-METHOD
              (%%REST (JAVA-TRANSLATE-UNIT FUNCTION)))
             (CL:SETF (%TRANSLATION FUNCTION) NULL)
             (CL:SETF (%CODE-REGISTER FUNCTION) NULL)
             (CL:SETQ ITER-001 (%%REST ITER-001))))
           (JAVA-UNBUMP-INDENT)
           (%%PRINT-STREAM (%NATIVE-STREAM *CURRENT-STREAM*) "}" EOL))
          (CL:WHEN (CL:NOT (CL:EQ CLASSOUTPUTSTREAM NULL))
           (FREE CLASSOUTPUTSTREAM))))))
      (CL:SETQ ITER-000 (%%REST ITER-000))))))
  :VOID)

;;; (DEFUN JAVA-PUSH-INTO-HASH-TABLE ...)

(CL:DEFUN JAVA-PUSH-INTO-HASH-TABLE (HT KEY OBJECT)
  (CL:LET* ((VALUE (LOOKUP HT KEY)))
   (CL:IF (CL:NOT (CL:EQ VALUE NULL))
    (INSERT-AT HT KEY (CONS OBJECT VALUE))
    (INSERT-AT HT KEY (CONS OBJECT NIL))))
  :VOID)

;;; (DEFUN JAVA-PUSH-INTO-STRING-HASH-TABLE ...)

(CL:DEFUN JAVA-PUSH-INTO-STRING-HASH-TABLE (HT KEY OBJECT)
  (CL:DECLARE (CL:TYPE CL:SIMPLE-STRING KEY))
  #+MCL
  (CL:CHECK-TYPE KEY CL:SIMPLE-STRING)
  (CL:LET* ((VALUE (LOOKUP HT KEY)))
   (CL:IF (CL:NOT (CL:EQ VALUE NULL))
    (INSERT-AT HT KEY (CONS OBJECT VALUE))
    (INSERT-AT HT KEY (CONS OBJECT NIL))))
  :VOID)

;;; (DEFUN (JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS? BOOLEAN) ...)

(CL:DEFUN JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS? (CLASSUNIT)
  (CL:LET*
   ((CLASS (%THE-OBJECT CLASSUNIT)) (MODULE (HOME-MODULE CLASSUNIT)))
   (CL:RETURN-FROM JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS?
    (STRING-EQL?
     (%WRAPPER-VALUE
      (JAVA-TRANSLATE-CLASS-NAMESTRING
       (WRAP-STRING
        (%SYMBOL-NAME
         (INTERN-SYMBOL-IN-MODULE (%SYMBOL-NAME (%CLASS-TYPE CLASS))
          (%HOME-CONTEXT (%CLASS-TYPE CLASS)) CL:NIL)))))
     (JAVA-YIELD-FLOTSAM-CLASS-NAME MODULE)))))

;;; (DEFUN JAVA-OUTPUT-ALL-UNITS-TO-FILE ...)

(CL:DEFUN JAVA-OUTPUT-ALL-UNITS-TO-FILE ()
  (CL:LET*
   ((STARTUPCLASSNAME NULL) (STARTUPHT (NEW-STRING-HASH-TABLE))
    (STARTUPCLASSLIST NIL) (METHODS NIL)
    (FLOTSAMFUNCTIONHT (NEW-HASH-TABLE)) (GLOBALSHT (NEW-HASH-TABLE))
    (CODEMODULESLIST (LIST)) (VERBATIMSTATEMENTS NIL) (CLASSES NIL)
    (CODEOUTPUTMODULE NULL))
   (INSERT-AT *JAVA-STELLA-PACKAGE-MAPPING* (WRAP-STRING "STELLAROOT")
    (WRAP-STRING (JAVA-STELLA-PACKAGE)))
   (CL:SETQ *TRANSLATIONUNITS* (REVERSE *TRANSLATIONUNITS*))
   (CL:LET*
    ((UNIT NULL) (ITER-000 (%THE-CONS-LIST *TRANSLATIONUNITS*)))
    (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-000 NIL)) DO
     (CL:SETQ UNIT (%%VALUE ITER-000))
     (CL:LET* ((TEST-VALUE-000 (%CATEGORY UNIT)))
      (CL:COND
       ((CL:OR
         (CL:EQ TEST-VALUE-000 SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD)
         (CL:EQ TEST-VALUE-000 SYM-JAVA-TRANSLATE-FILE-STELLA-MACRO))
        (CL:COND
         ((JAVA-FLOTSAM-FUNCTION? (%THE-OBJECT UNIT))
          (CL:SETQ CODEOUTPUTMODULE (HOME-MODULE (%THE-OBJECT UNIT)))
          (JAVA-PUSH-INTO-HASH-TABLE FLOTSAMFUNCTIONHT CODEOUTPUTMODULE
           UNIT)
          (INSERT-NEW CODEMODULESLIST CODEOUTPUTMODULE))
         ((METHOD-STARTUP-FUNCTION? (%THE-OBJECT UNIT))
          (CL:SETQ STARTUPCLASSNAME
           (JAVA-TRANSLATE-CLASS-NAMESTRING
            (WRAP-STRING
             (%WRAPPER-VALUE
              (DYNAMIC-SLOT-VALUE (%DYNAMIC-SLOTS (%THE-OBJECT UNIT))
               SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-STARTUP-CLASSNAME
               NULL-STRING-WRAPPER)))))
          (JAVA-PUSH-INTO-STRING-HASH-TABLE STARTUPHT
           (%WRAPPER-VALUE STARTUPCLASSNAME) UNIT)
          (CL:WHEN (CL:NOT (MEMBER? STARTUPCLASSLIST STARTUPCLASSNAME))
           (CL:SETQ STARTUPCLASSLIST
            (CONS STARTUPCLASSNAME STARTUPCLASSLIST))))
         (CL:T (CL:SETQ METHODS (CONS UNIT METHODS)))))
       ((CL:EQ TEST-VALUE-000
         SYM-JAVA-TRANSLATE-FILE-STELLA-PRINT-METHOD)
        (CL:SETQ METHODS (CONS UNIT METHODS)))
       ((CL:EQ TEST-VALUE-000 SYM-JAVA-TRANSLATE-FILE-STELLA-TYPE))
       ((CL:EQ TEST-VALUE-000 SYM-JAVA-TRANSLATE-FILE-STELLA-VERBATIM)
        (CL:SETQ VERBATIMSTATEMENTS (CONS UNIT VERBATIMSTATEMENTS)))
       ((CL:EQ TEST-VALUE-000 SYM-JAVA-TRANSLATE-FILE-STELLA-CLASS)
        (CL:SETQ CLASSES (CONS UNIT CLASSES)))
       ((CL:EQ TEST-VALUE-000
         SYM-JAVA-TRANSLATE-FILE-STELLA-GLOBAL-VARIABLE)
        (CL:SETQ CODEOUTPUTMODULE (HOME-MODULE (%THE-OBJECT UNIT)))
        (JAVA-PUSH-INTO-HASH-TABLE GLOBALSHT CODEOUTPUTMODULE UNIT)
        (INSERT-NEW CODEMODULESLIST CODEOUTPUTMODULE))
       (CL:T
        (CL:LET* ((STREAM-000 (NEW-OUTPUT-STRING-STREAM)))
         (%%PRINT-STREAM (%NATIVE-STREAM STREAM-000) "`" TEST-VALUE-000
          "' is not a valid case option")
         (CL:ERROR
          (NEW-STELLA-EXCEPTION (THE-STRING-READER STREAM-000)))))))
     (CL:SETQ ITER-000 (%%REST ITER-000))))
   (CL:LET* ((CLASSUNIT NULL) (ITER-001 CLASSES))
    (CL:LOOP WHILE (CL:NOT (CL:EQ ITER-001 NIL)) DO
     (CL:SETQ CLASSUNIT (%%VALUE ITER-001))
     (CL:IF (JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS? CLASSUNIT)
      (CL:LET*
       ((MODULE (HOME-MODULE (%THE-OBJECT CLASSUNIT))) (GLOBALS NIL)
        (FUNCTIONS NIL))
       (CL:LET* ((*MODULE* MODULE) (*CONTEXT* *MODULE*))
        (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
        (CL:SETQ GLOBALS (LOOKUP GLOBALSHT MODULE))
        (CL:WHEN (CL:EQ GLOBALS NULL) (CL:SETQ GLOBALS NIL))
        (CL:SETQ FUNCTIONS (LOOKUP FLOTSAMFUNCTIONHT MODULE))
        (CL:WHEN (CL:EQ FUNCTIONS NULL) (CL:SETQ FUNCTIONS NIL))
        (JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE
         (JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME MODULE CL:NIL) MODULE
         CLASSUNIT GLOBALS FUNCTIONS)
        (REMOVE CODEMODULESLIST MODULE)))
      (JAVA-OUTPUT-CLASS-UNIT-TO-FILE CLASSUNIT))
     (CL:SETQ ITER-001 (%%REST ITER-001))))
   (JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE GLOBALSHT FLOTSAMFUNCTIONHT
    (%THE-CONS-LIST CODEMODULESLIST))
   (JAVA-OUTPUT-STARTUP-UNITS-TO-FILE STARTUPHT STARTUPCLASSLIST))
  :VOID)

;;; (DEFUN JAVA-INITIALIZE-FILE-TRANSLATION ...)

(CL:DEFUN JAVA-INITIALIZE-FILE-TRANSLATION ()
  (CL:SETQ *JAVA-INDENT-CHARS* 0)
  :VOID)

;;; (DEFUN JAVA-TRANSLATE-FILE ...)

(CL:DEFUN JAVA-TRANSLATE-FILE (FILENAME)
  (TRANSLATE-FILE FILENAME KWD-JAVA-TRANSLATE-FILE-JAVA CL:NIL)
  :VOID)

;;; (DEFUN JAVA-TRANSLATE-FILE-AS-PART-OF-SYSTEM ...)

(CL:DEFUN JAVA-TRANSLATE-FILE-AS-PART-OF-SYSTEM (FILENAME)
  (TRANSLATE-FILE FILENAME KWD-JAVA-TRANSLATE-FILE-JAVA CL:T)
  :VOID)

;;; (DEFUN JAVA-TRANSLATE-WALKED-SYSTEM-UNITS ...)

(CL:DEFUN JAVA-TRANSLATE-WALKED-SYSTEM-UNITS (SYSTEMUNITS)
  (CL:LET*
   ((*TRANSLATIONUNITS* (CONCATENATE-SYSTEM-UNITS SYSTEMUNITS)))
   (CL:DECLARE (CL:SPECIAL *TRANSLATIONUNITS*))
   (CL:WHEN (CL:>= *TRANSLATIONVERBOSITYLEVEL* 1)
    (%%PRINT-STREAM (%NATIVE-STREAM STANDARD-OUTPUT)
     "Generating Java translations..." EOL))
   (JAVA-OUTPUT-ALL-UNITS-TO-FILE) (CLEAN-UP-TRANSLATION-UNITS-SPECIAL))
  :VOID)

;;; (DEFUN JAVA-TRANSLATE-SYSTEM ...)

(CL:DEFUN JAVA-TRANSLATE-SYSTEM (SYSTEMNAME)
  "Translate the system `systemName' to Java."
  (CL:DECLARE (CL:TYPE CL:SIMPLE-STRING SYSTEMNAME))
  #+MCL
  (CL:CHECK-TYPE SYSTEMNAME CL:SIMPLE-STRING)
  (%TRANSLATE-SYSTEM SYSTEMNAME
   (CONS-LIST KWD-JAVA-TRANSLATE-FILE-JAVA
    KWD-JAVA-TRANSLATE-FILE-TWO-PASS? TRUE-WRAPPER
    KWD-JAVA-TRANSLATE-FILE-FORCE-TRANSLATION? TRUE-WRAPPER
    KWD-JAVA-TRANSLATE-FILE-PRODUCTION-SETTINGS? TRUE-WRAPPER))
  :VOID)

(CL:DEFUN STARTUP-JAVA-TRANSLATE-FILE ()
  (CL:LET* ((*MODULE* *STELLA-MODULE*) (*CONTEXT* *MODULE*))
   (CL:DECLARE (CL:SPECIAL *MODULE* *CONTEXT*))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 2)
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-COMMON-LISP
     (INTERN-RIGID-SYMBOL-WRT-MODULE "COMMON-LISP" NULL 2))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-JAVA
     (INTERN-RIGID-SYMBOL-WRT-MODULE "JAVA" NULL 2))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-JPTRANS
     (INTERN-RIGID-SYMBOL-WRT-MODULE "JPTRANS" NULL 0))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-FUNCTION
     (INTERN-RIGID-SYMBOL-WRT-MODULE "FUNCTION" NULL 2))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-MINIMIZE-JAVA-PREFIXES
     (INTERN-RIGID-SYMBOL-WRT-MODULE "MINIMIZE-JAVA-PREFIXES" NULL 2))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-CONSTRUCTOR?
     (INTERN-RIGID-SYMBOL-WRT-MODULE "METHOD-CONSTRUCTOR?" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-NATIVE?
     (INTERN-RIGID-SYMBOL-WRT-MODULE "METHOD-NATIVE?" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD
     (INTERN-RIGID-SYMBOL-WRT-MODULE "METHOD" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-MACRO
     (INTERN-RIGID-SYMBOL-WRT-MODULE "MACRO" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-PRINT-METHOD
     (INTERN-RIGID-SYMBOL-WRT-MODULE "PRINT-METHOD" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-TYPE
     (INTERN-RIGID-SYMBOL-WRT-MODULE "TYPE" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-VERBATIM
     (INTERN-RIGID-SYMBOL-WRT-MODULE "VERBATIM" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-CLASS
     (INTERN-RIGID-SYMBOL-WRT-MODULE "CLASS" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-GLOBAL-VARIABLE
     (INTERN-RIGID-SYMBOL-WRT-MODULE "GLOBAL-VARIABLE" NULL 0))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-STARTUP-CLASSNAME
     (INTERN-RIGID-SYMBOL-WRT-MODULE "METHOD-STARTUP-CLASSNAME" NULL
      0))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-TWO-PASS?
     (INTERN-RIGID-SYMBOL-WRT-MODULE "TWO-PASS?" NULL 2))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-FORCE-TRANSLATION?
     (INTERN-RIGID-SYMBOL-WRT-MODULE "FORCE-TRANSLATION?" NULL 2))
    (CL:SETQ KWD-JAVA-TRANSLATE-FILE-PRODUCTION-SETTINGS?
     (INTERN-RIGID-SYMBOL-WRT-MODULE "PRODUCTION-SETTINGS?" NULL 2))
    (CL:SETQ SYM-JAVA-TRANSLATE-FILE-STELLA-STARTUP-JAVA-TRANSLATE-FILE
     (INTERN-RIGID-SYMBOL-WRT-MODULE "STARTUP-JAVA-TRANSLATE-FILE" NULL
      0)))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 6) (FINALIZE-CLASSES))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 7)
    (DEFINE-FUNCTION-OBJECT "CLT" "(DEFUN CLT ())" (CL:FUNCTION CLT)
     NULL)
    (DEFINE-FUNCTION-OBJECT "JT" "(DEFUN JT ())" (CL:FUNCTION JT) NULL)
    (DEFINE-FUNCTION-OBJECT "JPTRANS"
     "(DEFUN JPTRANS ((STATEMENT OBJECT)) :COMMAND? TRUE :PUBLIC? TRUE :EVALUATE-ARGUMENTS? FALSE :DOCUMENTATION \"Translate `statement' to C++ and print the result.\")"
     (CL:FUNCTION %JPTRANS) NULL)
    (DEFINE-METHOD-OBJECT
     "(DEFMETHOD (JAVA-MAKE-CODE-OUTPUT-FILE-NAME FILE-NAME) ((BAREFILE FILE-NAME) (DONTTRUNCATE? BOOLEAN)))"
     (CL:FUNCTION JAVA-MAKE-CODE-OUTPUT-FILE-NAME) NULL)
    (DEFINE-METHOD-OBJECT
     "(DEFMETHOD (JAVA-MAKE-CODE-OUTPUT-FILE-NAME FILE-NAME) ((SOURCE CLASS) (DONTTRUNCATE? BOOLEAN)))"
     (CL:FUNCTION JAVA-MAKE-CODE-OUTPUT-FILE-NAME) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME"
     "(DEFUN (JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME FILE-NAME) ((MODULE MODULE) (DONTTRUNCATE? BOOLEAN)))"
     (CL:FUNCTION JAVA-MAKE-GLOBAL-OUTPUT-FILE-NAME) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE"
     "(DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE ((GLOBALSHT HASH-TABLE) (FUNCTIONHT HASH-TABLE) (CODEMODULELIST (CONS OF MODULE))))"
     (CL:FUNCTION JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT
     "JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE"
     "(DEFUN JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE ((CLASSOUTPUTFILE FILE-NAME) (MODULE MODULE) (CLASSUNIT TRANSLATION-UNIT) (GLOBALS (CONS OF TRANSLATION-UNIT)) (FUNCTIONS (CONS OF TRANSLATION-UNIT))))"
     (CL:FUNCTION JAVA-OUTPUT-FLOTSAM-UNITS-TO-FILE-FOR-MODULE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-FILE-HEADER"
     "(DEFUN JAVA-OUTPUT-FILE-HEADER ((STREAM OUTPUT-STREAM) (FILENAME FILE-NAME)))"
     (CL:FUNCTION JAVA-OUTPUT-FILE-HEADER) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-CLASS-TO-FILE"
     "(DEFUN JAVA-OUTPUT-CLASS-TO-FILE ((CLASS CLASS)))"
     (CL:FUNCTION JAVA-OUTPUT-CLASS-TO-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-CLASS-UNIT-TO-FILE"
     "(DEFUN JAVA-OUTPUT-CLASS-UNIT-TO-FILE ((CLASSUNIT TRANSLATION-UNIT)))"
     (CL:FUNCTION JAVA-OUTPUT-CLASS-UNIT-TO-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-FLOTSAM-FUNCTION?"
     "(DEFUN (JAVA-FLOTSAM-FUNCTION? BOOLEAN) ((METHOD METHOD-SLOT)))"
     (CL:FUNCTION JAVA-FLOTSAM-FUNCTION?) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-STARTUP-UNITS-TO-FILE"
     "(DEFUN JAVA-OUTPUT-STARTUP-UNITS-TO-FILE ((STARTUPHT STRING-HASH-TABLE) (KEYLIST (CONS OF STRING-WRAPPER))))"
     (CL:FUNCTION JAVA-OUTPUT-STARTUP-UNITS-TO-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-PUSH-INTO-HASH-TABLE"
     "(DEFUN JAVA-PUSH-INTO-HASH-TABLE ((HT HASH-TABLE) (KEY OBJECT) (OBJECT OBJECT)))"
     (CL:FUNCTION JAVA-PUSH-INTO-HASH-TABLE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-PUSH-INTO-STRING-HASH-TABLE"
     "(DEFUN JAVA-PUSH-INTO-STRING-HASH-TABLE ((HT STRING-HASH-TABLE) (KEY STRING) (OBJECT OBJECT)))"
     (CL:FUNCTION JAVA-PUSH-INTO-STRING-HASH-TABLE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS?"
     "(DEFUN (JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS? BOOLEAN) ((CLASSUNIT TRANSLATION-UNIT)))"
     (CL:FUNCTION JAVA-CLASS-UNIT-DEFINES-FLOTSAM-CLASS?) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-OUTPUT-ALL-UNITS-TO-FILE"
     "(DEFUN JAVA-OUTPUT-ALL-UNITS-TO-FILE ())"
     (CL:FUNCTION JAVA-OUTPUT-ALL-UNITS-TO-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-INITIALIZE-FILE-TRANSLATION"
     "(DEFUN JAVA-INITIALIZE-FILE-TRANSLATION ())"
     (CL:FUNCTION JAVA-INITIALIZE-FILE-TRANSLATION) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-TRANSLATE-FILE"
     "(DEFUN JAVA-TRANSLATE-FILE ((FILENAME FILE-NAME)) :PUBLIC? TRUE)"
     (CL:FUNCTION JAVA-TRANSLATE-FILE) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-TRANSLATE-FILE-AS-PART-OF-SYSTEM"
     "(DEFUN JAVA-TRANSLATE-FILE-AS-PART-OF-SYSTEM ((FILENAME FILE-NAME)))"
     (CL:FUNCTION JAVA-TRANSLATE-FILE-AS-PART-OF-SYSTEM) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-TRANSLATE-WALKED-SYSTEM-UNITS"
     "(DEFUN JAVA-TRANSLATE-WALKED-SYSTEM-UNITS ((SYSTEMUNITS SYSTEM-UNITS-ALIST)))"
     (CL:FUNCTION JAVA-TRANSLATE-WALKED-SYSTEM-UNITS) NULL)
    (DEFINE-FUNCTION-OBJECT "JAVA-TRANSLATE-SYSTEM"
     "(DEFUN JAVA-TRANSLATE-SYSTEM ((SYSTEMNAME STRING)) :DOCUMENTATION \"Translate the system `systemName' to Java.\" :PUBLIC? TRUE)"
     (CL:FUNCTION JAVA-TRANSLATE-SYSTEM) NULL)
    (DEFINE-FUNCTION-OBJECT "STARTUP-JAVA-TRANSLATE-FILE"
     "(DEFUN STARTUP-JAVA-TRANSLATE-FILE () :PUBLIC? TRUE)"
     (CL:FUNCTION STARTUP-JAVA-TRANSLATE-FILE) NULL)
    (CL:LET*
     ((FUNCTION
       (LOOKUP-FUNCTION
        SYM-JAVA-TRANSLATE-FILE-STELLA-STARTUP-JAVA-TRANSLATE-FILE)))
     (SET-DYNAMIC-SLOT-VALUE (%DYNAMIC-SLOTS FUNCTION)
      SYM-JAVA-TRANSLATE-FILE-STELLA-METHOD-STARTUP-CLASSNAME
      (WRAP-STRING "_StartupJavaTranslateFile") NULL-STRING-WRAPPER)))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 8) (FINALIZE-SLOTS)
    (CLEANUP-UNFINALIZED-CLASSES))
   (CL:WHEN (CURRENT-STARTUP-TIME-PHASE? 9)
    (%IN-MODULE (COPY-CONS-TREE (WRAP-STRING "STELLA")))
    (DEFINE-STELLA-GLOBAL-VARIABLE-FROM-STRINGIFIED-SOURCE
     "(DEFSPECIAL *CURRENT-JAVA-OUTPUT-CLASS* CLASS NULL :PUBLIC? FALSE :DOCUMENTATION \"Holds the current Stella class being output in Java\")")
    (REGISTER-NATIVE-NAME SYM-JAVA-TRANSLATE-FILE-STELLA-JPTRANS
     KWD-JAVA-TRANSLATE-FILE-COMMON-LISP
     KWD-JAVA-TRANSLATE-FILE-FUNCTION)))
  :VOID)
