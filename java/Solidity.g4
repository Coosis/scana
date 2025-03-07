// Copyright 2020 Gonçalo Sá <goncalo.sa@consensys.net>
// Copyright 2016-2019 Federico Bond <federicobond@gmail.com>
// Licensed under the MIT license. See LICENSE file in the project root for details.

grammar Solidity;

sourceUnit
  : (
    pragmaDirective
    | importDirective
    | contractDefinition
    | enumDefinition
    | structDefinition
    | functionDefinition
    | fileLevelConstant
    | customErrorDefinition
    )* EOF ;

pragmaDirective
  : 'pragma' pragmaName pragmaValue ';' ;

pragmaName
  : identifier ;

pragmaValue
  : version | expression ;

version
  : versionConstraint ('||'? versionConstraint)* ;

versionOperator
  : '^' | '~' | '>=' | '>' | '<' | '<=' | '=' ;

versionConstraint
  : versionOperator? VersionLiteral
  | versionOperator? DecimalNumber ;

importDeclaration
  : identifier ('as' identifier)? ;

importDirective
  : 'import' importPath ('as' identifier)? ';'
  | 'import' ('*' | identifier) ('as' identifier)? 'from' importPath ';'
  | 'import' '{' importDeclaration ( ',' importDeclaration )* '}' 'from' importPath ';' ;

importPath : StringLiteralFragment ;

contractDefinition
  : 'abstract'? ( 'contract' | 'interface' | 'library' ) identifier
    ( 'is' inheritanceSpecifier (',' inheritanceSpecifier )* )?
    '{' contractPart* '}' ;

inheritanceSpecifier
  : userDefinedTypeName ( '(' expressionList? ')' )? ;

contractPart
  : stateVariableDeclaration
  | usingForDeclaration
  | structDefinition
  | modifierDefinition
  | functionDefinition
  | eventDefinition
  | enumDefinition
  | customErrorDefinition;

stateVariableDeclaration
  : typeName
    ( PublicKeyword | InternalKeyword | PrivateKeyword | ConstantKeyword | ImmutableKeyword | overrideSpecifier )*
    identifier ('=' expression)? ';' ;

fileLevelConstant
  : typeName ConstantKeyword identifier '=' expression ';' ;

customErrorDefinition
  : 'error' identifier parameterList ';' ;

usingForDeclaration
  : 'using' identifier 'for' ('*' | typeName) ';' ;

structDefinition
  : 'struct' identifier
    '{' ( variableDeclaration ';' (variableDeclaration ';')* )? '}' ;

modifierDefinition
  : 'modifier' identifier parameterList? ( VirtualKeyword | overrideSpecifier )* ( ';' | block ) ;

modifierInvocation
  : identifier ( '(' expressionList? ')' )? ;

functionDefinition
  : functionDescriptor parameterList modifierList returnParameters? ( ';' | block ) ;

functionDescriptor
  : 'function' identifier?
  | ConstructorKeyword
  | FallbackKeyword
  | ReceiveKeyword ;

returnParameters
  : 'returns' parameterList ;

modifierList
  : (ExternalKeyword | PublicKeyword | InternalKeyword | PrivateKeyword | VirtualKeyword | stateMutability | modifierInvocation | overrideSpecifier )* ;

eventDefinition
  : 'event' identifier eventParameterList AnonymousKeyword? ';' ;

enumValue
  : identifier ;

enumDefinition
  : 'enum' identifier '{' enumValue? (',' enumValue)* '}' ;

parameterList
  : '(' ( parameter (',' parameter)* )? ')' ;

parameter
  : typeName storageLocation? identifier? ;

eventParameterList
  : '(' ( eventParameter (',' eventParameter)* )? ')' ;

eventParameter
  : typeName IndexedKeyword? identifier? ;

functionTypeParameterList
  : '(' ( functionTypeParameter (',' functionTypeParameter)* )? ')' ;

functionTypeParameter
  : typeName storageLocation? ;

variableDeclaration
  : typeName storageLocation? identifier ;

typeName
  : elementaryTypeName
  | userDefinedTypeName
  | mapping
  | typeName '[' expression? ']'
  | functionTypeName
  | 'address' 'payable' ;

userDefinedTypeName
  : identifier ( '.' identifier )* ;

mappingKey
  : elementaryTypeName
  | userDefinedTypeName ;

mapping
  : 'mapping' '(' mappingKey '=>' typeName ')' ;

functionTypeName
  : 'function' functionTypeParameterList
    ( InternalKeyword | ExternalKeyword | stateMutability )*
    ( 'returns' functionTypeParameterList )? ;

storageLocation
  : 'memory' | 'storage' | 'calldata';

stateMutability
  : PureKeyword | ConstantKeyword | ViewKeyword | PayableKeyword ;

block
  : '{' statement* '}' ;

statement
  : ifStatement
  | tryStatement
  | whileStatement
  | forStatement
  | block
  | inlineAssemblyStatement
  | doWhileStatement
  | continueStatement
  | breakStatement
  | returnStatement
  | throwStatement
  | emitStatement
  | simpleStatement
  | uncheckedStatement
  | revertStatement;

expressionStatement
  : expression ';' ;

ifStatement
  : 'if' '(' expression ')' statement ( 'else' statement )? ;

tryStatement : 'try' expression returnParameters? block catchClause+ ;

// In reality catch clauses still are not processed as below
// the identifier can only be a set string: "Error". But plans
// of the Solidity team include possible expansion so we'll
// leave this as is, befitting with the Solidity docs.
catchClause : 'catch' ( identifier? parameterList )? block ;

whileStatement
  : 'while' '(' expression ')' statement ;

simpleStatement
  : ( variableDeclarationStatement | expressionStatement ) ;

uncheckedStatement
  : 'unchecked' block ;

forStatement
  : 'for' '(' ( simpleStatement | ';' ) ( expressionStatement | ';' ) expression? ')' statement ;

inlineAssemblyStatement
  : 'assembly' StringLiteralFragment? assemblyBlock ;

doWhileStatement
  : 'do' statement 'while' '(' expression ')' ';' ;

continueStatement
  : 'continue' ';' ;

breakStatement
  : 'break' ';' ;

returnStatement
  : 'return' expression? ';' ;

throwStatement
  : 'throw' ';' ;

emitStatement
  : 'emit' functionCall ';' ;

revertStatement
  : 'revert' functionCall ';' ;

variableDeclarationStatement
  : ( 'var' identifierList | variableDeclaration | '(' variableDeclarationList ')' ) ( '=' expression )? ';';

variableDeclarationList
  : variableDeclaration? (',' variableDeclaration? )* ;

identifierList
  : '(' ( identifier? ',' )* identifier? ')' ;

elementaryTypeName
  : 'address' | 'bool' | 'string' | 'var' | Int | Uint | 'byte' | Byte | Fixed | Ufixed ;

Int
  : 'int' | 'int8' | 'int16' | 'int24' | 'int32' | 'int40' | 'int48' | 'int56' | 'int64' | 'int72' | 'int80' | 'int88' | 'int96' | 'int104' | 'int112' | 'int120' | 'int128' | 'int136' | 'int144' | 'int152' | 'int160' | 'int168' | 'int176' | 'int184' | 'int192' | 'int200' | 'int208' | 'int216' | 'int224' | 'int232' | 'int240' | 'int248' | 'int256' ;

Uint
  : 'uint' | 'uint8' | 'uint16' | 'uint24' | 'uint32' | 'uint40' | 'uint48' | 'uint56' | 'uint64' | 'uint72' | 'uint80' | 'uint88' | 'uint96' | 'uint104' | 'uint112' | 'uint120' | 'uint128' | 'uint136' | 'uint144' | 'uint152' | 'uint160' | 'uint168' | 'uint176' | 'uint184' | 'uint192' | 'uint200' | 'uint208' | 'uint216' | 'uint224' | 'uint232' | 'uint240' | 'uint248' | 'uint256' ;

Byte
  : 'bytes' | 'bytes1' | 'bytes2' | 'bytes3' | 'bytes4' | 'bytes5' | 'bytes6' | 'bytes7' | 'bytes8' | 'bytes9' | 'bytes10' | 'bytes11' | 'bytes12' | 'bytes13' | 'bytes14' | 'bytes15' | 'bytes16' | 'bytes17' | 'bytes18' | 'bytes19' | 'bytes20' | 'bytes21' | 'bytes22' | 'bytes23' | 'bytes24' | 'bytes25' | 'bytes26' | 'bytes27' | 'bytes28' | 'bytes29' | 'bytes30' | 'bytes31' | 'bytes32' ;

Fixed
  : 'fixed' | ( 'fixed' [0-9]+ 'x' [0-9]+ ) ;

Ufixed
  : 'ufixed' | ( 'ufixed' [0-9]+ 'x' [0-9]+ ) ;

expression
  : expression ('++' | '--')
  | 'new' typeName
  | expression '[' expression ']'
  | expression '[' expression? ':' expression? ']'
  | expression '.' identifier
  | expression '{' nameValueList '}'
  | expression '(' functionCallArguments ')'
  | '(' expression ')'
  | ('++' | '--') expression
  | ('+' | '-') expression
  | ('after' | 'delete') expression
  | '!' expression
  | '~' expression
  | expression '**' expression
  | expression ('*' | '/' | '%') expression
  | expression ('+' | '-') expression
  | expression ('<<' | '>>') expression
  | expression '&' expression
  | expression '^' expression
  | expression '|' expression
  | expression ('<' | '>' | '<=' | '>=') expression
  | expression ('==' | '!=') expression
  | expression '&&' expression
  | expression '||' expression
  | expression '?' expression ':' expression
  | expression ('=' | '|=' | '^=' | '&=' | '<<=' | '>>=' | '+=' | '-=' | '*=' | '/=' | '%=') expression
  | primaryExpression ;

primaryExpression
  : BooleanLiteral
  | numberLiteral
  | hexLiteral
  | stringLiteral
  | identifier ('[' ']')?
  | TypeKeyword
  | PayableKeyword
  | tupleExpression
  | typeNameExpression ('[' ']')? ;

expressionList
  : expression (',' expression)* ;

nameValueList
  : nameValue (',' nameValue)* ','? ;

nameValue
  : identifier ':' expression ;

functionCallArguments
  : '{' nameValueList? '}'
  | expressionList? ;

functionCall
  : expression '(' functionCallArguments ')' ;

assemblyBlock
  : '{' assemblyItem* '}' ;

assemblyItem
  : identifier
  | assemblyBlock
  | assemblyExpression
  | assemblyLocalDefinition
  | assemblyAssignment
  | assemblyStackAssignment
  | labelDefinition
  | assemblySwitch
  | assemblyFunctionDefinition
  | assemblyFor
  | assemblyIf
  | BreakKeyword
  | ContinueKeyword
  | LeaveKeyword
  | subAssembly
  | numberLiteral
  | stringLiteral
  | hexLiteral ;

assemblyExpression
  : assemblyCall | assemblyLiteral | assemblyMember ;

assemblyMember
  : identifier '.' identifier ;

assemblyCall
  : ( 'return' | 'address' | 'byte' | identifier ) ( '(' assemblyExpression? ( ',' assemblyExpression )* ')' )? ;

assemblyLocalDefinition
  : 'let' assemblyIdentifierOrList ( ':=' assemblyExpression )? ;

assemblyAssignment
  : assemblyIdentifierOrList ':=' assemblyExpression ;

assemblyIdentifierOrList
  : identifier | assemblyMember | '(' assemblyIdentifierList ')' ;

assemblyIdentifierList
  : identifier ( ',' identifier )* ;

assemblyStackAssignment
  : '=:' identifier ;

labelDefinition
  : identifier ':' ;

assemblySwitch
  : 'switch' assemblyExpression assemblyCase* ;

assemblyCase
  : 'case' assemblyLiteral assemblyBlock
  | 'default' assemblyBlock ;

assemblyFunctionDefinition
  : 'function' identifier '(' assemblyIdentifierList? ')'
    assemblyFunctionReturns? assemblyBlock ;

assemblyFunctionReturns
  : ( '->' assemblyIdentifierList ) ;

assemblyFor
  : 'for' ( assemblyBlock | assemblyExpression )
    assemblyExpression ( assemblyBlock | assemblyExpression ) assemblyBlock ;

assemblyIf
  : 'if' assemblyExpression assemblyBlock ;

assemblyLiteral
  : stringLiteral | DecimalNumber | HexNumber | hexLiteral ;

subAssembly
  : 'assembly' identifier assemblyBlock ;

tupleExpression
  : '(' ( expression? ( ',' expression? )* ) ')'
  | '[' ( expression ( ',' expression )* )? ']' ;

typeNameExpression
  : elementaryTypeName
  | userDefinedTypeName ;

numberLiteral
  : (DecimalNumber | HexNumber) NumberUnit? ;

// some keywords need to be added here to avoid ambiguities
// for example, "revert" is a keyword but it can also be a function name
identifier
  : ('from' | 'calldata' | 'receive' | 'callback' | 'revert' | 'error' | ConstructorKeyword | PayableKeyword | LeaveKeyword | Identifier) ;

BooleanLiteral
  : 'true' | 'false' ;

DecimalNumber
  : ( DecimalDigits | (DecimalDigits? '.' DecimalDigits) ) ( [eE] DecimalDigits )? ;

fragment
DecimalDigits
  : [0-9] ( '_'? [0-9] )* ;

HexNumber
  : '0' [xX] HexDigits ;

fragment
HexDigits
  : HexCharacter ( '_'? HexCharacter )* ;

NumberUnit
  : 'wei' | 'gwei' | 'szabo' | 'finney' | 'ether'
  | 'seconds' | 'minutes' | 'hours' | 'days' | 'weeks' | 'years' ;

hexLiteral : HexLiteralFragment+ ;

HexLiteralFragment : 'hex' ('"' HexDigits? '"' | '\'' HexDigits? '\'') ;

fragment
HexPair
  : HexCharacter HexCharacter ;

fragment
HexCharacter
  : [0-9A-Fa-f] ;

ReservedKeyword
  : 'abstract'
  | 'after'
  | 'case'
  | 'catch'
  | 'default'
  | 'final'
  | 'in'
  | 'inline'
  | 'let'
  | 'match'
  | 'null'
  | 'of'
  | 'relocatable'
  | 'static'
  | 'switch'
  | 'try'
  | 'typeof' ;

AnonymousKeyword : 'anonymous' ;
BreakKeyword : 'break' ;
ConstantKeyword : 'constant' ;
ImmutableKeyword : 'immutable' ;
ContinueKeyword : 'continue' ;
LeaveKeyword : 'leave' ;
ExternalKeyword : 'external' ;
IndexedKeyword : 'indexed' ;
InternalKeyword : 'internal' ;
PayableKeyword : 'payable' ;
PrivateKeyword : 'private' ;
PublicKeyword : 'public' ;
VirtualKeyword : 'virtual' ;
PureKeyword : 'pure' ;
TypeKeyword : 'type' ;
ViewKeyword : 'view' ;

ConstructorKeyword : 'constructor' ;
FallbackKeyword : 'fallback' ;
ReceiveKeyword : 'receive' ;

overrideSpecifier : 'override' ( '(' userDefinedTypeName (',' userDefinedTypeName)* ')' )? ;

Identifier
  : IdentifierStart IdentifierPart* ;

fragment
IdentifierStart
  : [a-zA-Z$_] ;

fragment
IdentifierPart
  : [a-zA-Z0-9$_] ;

stringLiteral
  : StringLiteralFragment+ ;

StringLiteralFragment
  : 'unicode'? '"' DoubleQuotedStringCharacter* '"'
  | 'unicode'? '\'' SingleQuotedStringCharacter* '\'' ;

fragment
DoubleQuotedStringCharacter
  : ~["\r\n\\] | ('\\' .) ;

fragment
SingleQuotedStringCharacter
  : ~['\r\n\\] | ('\\' .) ;

VersionLiteral
  : [0-9]+ '.' [0-9]+ ('.' [0-9]+)? ;

WS
  : [ \t\r\n\u000C]+ -> skip ;

COMMENT
  : '/*' .*? '*/' -> channel(HIDDEN) ;

LINE_COMMENT
  : '//' ~[\r\n]* -> channel(HIDDEN) ;
