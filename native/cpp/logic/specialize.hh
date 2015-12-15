//  -*- Mode: C++ -*-

// specialize.hh

/*
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
 | Portions created by the Initial Developer are Copyright (C) 1997-2006      |
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
*/


namespace logic {
  using namespace stella;

// Class definitions:
class AbstractPropositionsIterator : public Iterator {
// Iterator class that can generate sets of propositions matching
// its `selection-pattern'.
public:
  Cons* selectionPattern;
  Iterator* propositionCursor;
  Cons* equivalentsStack;
public:
  virtual Surrogate* primaryType();
};

class TruePropositionsIterator : public AbstractPropositionsIterator {
// Iterator class that can generate sets of true propositions
// matching its `selection-pattern'.
public:
  // Truth-value of the most recently generated proposition (or
  // projected argument thereof).  This truth value is not necessarily the strictest
  // and might have involved defaults.
  TruthValue* truthValue;
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};

class SpecializingPropositionsIterator : public TruePropositionsIterator {
// Iterator class that can generate sets of true propositions
// matching its `selection-pattern' or a more specific pattern that substitutes
// one of the relations in `specializing-relations'.
public:
  Cons* specializingRelations;
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};

class TransitiveClosureIterator : public Iterator {
// Iterator that visits all nodes reachable using an
// embedded adjacency function.
public:
  cpp_function_code allocateAdjacencyIteratorFunction;
  cpp_function_code filterP;
  Cons* adjacencyIteratorStack;
  Cons* beenThereList;
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};

class SupportedClosureIterator : public TransitiveClosureIterator {
// Iterator that visits all objects reachable via true link propositions
// generated by an embedded link proposition iterator.  Each new object reached
// is represented as an `(<object> <truth-value>)' pair, where <truth-value> is
// the cumulative truth value of the links followed from the start to reach it.
// The embedded `allocate-adjacency-iterator-function' needs to be able to take
// an `(<object> <truth-value>)' pair as an argument which is different than the
// requirement for TRANSITIVE-CLOSURE-ITERATOR's.
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};

class DirectlyLinkedObjectsIterator : public TruePropositionsIterator {
public:
  boolean inverseP;
  TruthValue* rootTruthValue;
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};

class ClashingPropositionsIterator : public TruePropositionsIterator {
public:
  Proposition* referenceProposition;
public:
  virtual Surrogate* primaryType();
  virtual boolean nextP();
};


// Global declarations:
extern Iterator* EMPTY_PROPOSITIONS_ITERATOR;
extern TaxonomyGraph* oIMPLICATION_SUBSUMPTION_GRAPHo;

// Function signatures:
AbstractPropositionsIterator* newAbstractPropositionsIterator();
Object* accessAbstractPropositionsIteratorSlotValue(AbstractPropositionsIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
TruePropositionsIterator* newTruePropositionsIterator();
Object* accessTruePropositionsIteratorSlotValue(TruePropositionsIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
SpecializingPropositionsIterator* newSpecializingPropositionsIterator();
Object* accessSpecializingPropositionsIteratorSlotValue(SpecializingPropositionsIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
TruthValue* propositionsIteratorTruthValue(Iterator* self);
Cons* nextEquivalentSelectionPattern(AbstractPropositionsIterator* self);
TruthValue* propositionTruthValue(Proposition* proposition);
boolean truePropositionP(Proposition* proposition);
boolean truePropositionsIteratorDnextP(TruePropositionsIterator* self);
boolean specializingPropositionsIteratorDnextP(SpecializingPropositionsIterator* self);
boolean emptyPropositionsIndexP(SequenceIndex* index, Object* primarykey, boolean specializeP);
Iterator* allTrueDependentPropositions(Object* self, Surrogate* relation, boolean specializeP);
Iterator* allTrueDependentIsaPropositions(Object* self);
boolean argumentsUnifyWithArgumentsP(Proposition* subproposition, Proposition* referenceproposition);
boolean argumentsEqualArgumentsP(Proposition* subproposition, Proposition* referenceproposition);
boolean argumentsMatchArgumentsP(Proposition* subproposition, Proposition* referenceproposition);
boolean prefixArgumentsEqualArgumentsP(Proposition* subproposition, Proposition* referenceproposition);
Iterator* allMatchingPropositions(Proposition* self);
Cons* allPropositionsMatchingArguments(Cons* arguments, Surrogate* relation, boolean specializeP);
Cons* allDefiningPropositions(Object* outputargument, Surrogate* relation, boolean specializeP);
boolean helpMemoizeTestPropertyP(Object* self, Surrogate* relation);
boolean testPropertyP(Object* self, Surrogate* relation);
boolean helpMemoizeTestIsaP(Object* member, Surrogate* type);
boolean testIsaP(Object* member, Surrogate* type);
Object* helpMemoizeAccessBinaryValue(Object* self, Surrogate* relation);
Object* accessBinaryValue(Object* self, Surrogate* relation);
boolean testCollectionofMemberOfP(Object* member, Surrogate* type);
TransitiveClosureIterator* newTransitiveClosureIterator();
Object* accessTransitiveClosureIteratorSlotValue(TransitiveClosureIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
boolean transitiveClosureIteratorDnextP(TransitiveClosureIterator* self);
Iterator* allocateTransitiveClosureIterator(Object* startnode, cpp_function_code allocateadjacencyiterator, cpp_function_code filterfunction);
SupportedClosureIterator* newSupportedClosureIterator();
Object* accessSupportedClosureIteratorSlotValue(SupportedClosureIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
SupportedClosureIterator* allocateSupportedClosureIterator(Cons* startnode, cpp_function_code allocateadjacencyiterator, cpp_function_code filterfunction);
DirectlyLinkedObjectsIterator* newDirectlyLinkedObjectsIterator();
Object* accessDirectlyLinkedObjectsIteratorSlotValue(DirectlyLinkedObjectsIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
Iterator* allDirectlyLinkedObjects(Object* self, Surrogate* relation, boolean inverseP);
Iterator* allDirectSupercollections(LogicObject* self, boolean performfilteringP);
Iterator* allDirectSupercollectionsWithEquivalents(LogicObject* self);
Iterator* allDirectSubcollections(LogicObject* self, boolean performfilteringP);
Iterator* allDirectSubcollectionsWithEquivalents(LogicObject* self);
Iterator* allSupercollections(LogicObject* self);
Iterator* allSubcollections(LogicObject* self);
Cons* allIsaCollections(Object* self);
Cons* allSupportedNamedSubcollections(LogicObject* self);
TruePropositionsIterator* allDirectlyLinkedSubcollections(Object* self);
Cons* helpAllSupportedNamedSubcollections(LogicObject* self);
boolean valueClashesWithSkolemP(Skolem* skolem, Object* value);
boolean clashesWithFunctionPropositionP(Proposition* nextproposition, Proposition* referenceproposition);
ClashingPropositionsIterator* newClashingPropositionsIterator();
Object* accessClashingPropositionsIteratorSlotValue(ClashingPropositionsIterator* self, Symbol* slotname, Object* value, boolean setvalueP);
Iterator* allClashingPropositions(Proposition* self);
List* relationsWithDescriptions();
void buildSubsumptionTaxonomyGraph();
void clearImplicationSubsumptionGraph();
void initializeImplicationSubsumptionGraph();
TaxonomyNode* findDescriptionImplicationSubsumptionNode(Description* description);
TaxonomyNode* createDescriptionImplicationSubsumptionNode(Description* description, TaxonomyNode* parentnode);
TaxonomyNode* findOrCreateDescriptionImplicationSubsumptionNode(Description* description);
Description* createDescriptionForStellaRelationAndAncestors(Relation* self);
void addTaxonomyImpliesSubsumesLink(Description* taildescription, Description* headdescription);
void dropTaxonomyImpliesSubsumesLink(Description* taildescription, Description* headdescription);
boolean taxonomyImpliesOrIsSubsumedP(Relation* premise, Relation* conclusion);
void helpStartupSpecialize1();
void helpStartupSpecialize2();
void helpStartupSpecialize3();
void startupSpecialize();

// Auxiliary global declarations:
extern Surrogate* SGT_SPECIALIZE_LOGIC_ABSTRACT_PROPOSITIONS_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_SELECTION_PATTERN;
extern Symbol* SYM_SPECIALIZE_LOGIC_PROPOSITION_CURSOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_EQUIVALENTS_STACK;
extern Surrogate* SGT_SPECIALIZE_LOGIC_TRUE_PROPOSITIONS_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_TRUTH_VALUE;
extern Surrogate* SGT_SPECIALIZE_LOGIC_SPECIALIZING_PROPOSITIONS_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_SPECIALIZING_RELATIONS;
extern Surrogate* SGT_SPECIALIZE_LOGIC_DESCRIPTION_EXTENSION_ITERATOR;
extern Keyword* KWD_SPECIALIZE_RELATION;
extern Surrogate* SGT_SPECIALIZE_LOGIC_LOGIC_OBJECT;
extern Keyword* KWD_SPECIALIZE_DEPENDENTS;
extern Keyword* KWD_SPECIALIZE_ISA;
extern Surrogate* SGT_SPECIALIZE_LOGIC_PROPOSITION;
extern Keyword* KWD_SPECIALIZE_FUNCTION;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_TEST_PROPERTYp_MEMO_TABLE_000;
extern Surrogate* SGT_SPECIALIZE_STELLA_THING;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_CLASS;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_RELATION;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_FUNCTION;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_COLLECTION;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_SET;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_TEST_ISAp_MEMO_TABLE_000;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_TEST_ISAp_MEMO_TABLE_001;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_ACCESS_BINARY_VALUE_MEMO_TABLE_000;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_COLLECTIONOF;
extern Surrogate* SGT_SPECIALIZE_LOGIC_TRANSITIVE_CLOSURE_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_ALLOCATE_ADJACENCY_ITERATOR_FUNCTION;
extern Symbol* SYM_SPECIALIZE_LOGIC_FILTERp;
extern Symbol* SYM_SPECIALIZE_LOGIC_ADJACENCY_ITERATOR_STACK;
extern Symbol* SYM_SPECIALIZE_LOGIC_BEEN_THERE_LIST;
extern Surrogate* SGT_SPECIALIZE_LOGIC_SUPPORTED_CLOSURE_ITERATOR;
extern Surrogate* SGT_SPECIALIZE_LOGIC_DIRECTLY_LINKED_OBJECTS_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_INVERSEp;
extern Symbol* SYM_SPECIALIZE_LOGIC_ROOT_TRUTH_VALUE;
extern Surrogate* SGT_SPECIALIZE_LOGIC_DESCRIPTION;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_SUBSET_OF;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_ALL_SUPERCOLLECTIONS_MEMO_TABLE_000;
extern Surrogate* SGT_SPECIALIZE_PL_KERNEL_KB_MEMBER_OF;
extern Surrogate* SGT_SPECIALIZE_LOGIC_F_ALL_SUPPORTED_NAMED_SUBCOLLECTIONS_MEMO_TABLE_000;
extern Surrogate* SGT_SPECIALIZE_STELLA_CONS;
extern Surrogate* SGT_SPECIALIZE_LOGIC_NAMED_DESCRIPTION;
extern Surrogate* SGT_SPECIALIZE_STELLA_NUMBER;
extern Surrogate* SGT_SPECIALIZE_LOGIC_SKOLEM;
extern Surrogate* SGT_SPECIALIZE_LOGIC_CLASHING_PROPOSITIONS_ITERATOR;
extern Symbol* SYM_SPECIALIZE_LOGIC_REFERENCE_PROPOSITION;
extern Symbol* SYM_SPECIALIZE_LOGIC_DESCRIPTION;
extern Symbol* SYM_SPECIALIZE_STELLA_TAXONOMY_NODE;
extern Symbol* SYM_SPECIALIZE_LOGIC_STARTUP_SPECIALIZE;
extern Symbol* SYM_SPECIALIZE_STELLA_METHOD_STARTUP_CLASSNAME;


} // end of namespace logic
