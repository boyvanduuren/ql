%{

// Copyright (c) 2014 The ql Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
		
// Inital yacc source generated by ebnf2y[1]
// at 2013-10-04 23:10:47.861401015 +0200 CEST
//
//  $ ebnf2y -o ql.y -oe ql.ebnf -start StatementList -pkg ql -p _
//
// CAUTION: If this file is a Go source file (*.go), it was generated
// automatically by '$ go tool yacc' from a *.y file - DO NOT EDIT in that case!
// 
//   [1]: http://github.com/cznic/ebnf2y

package ql

import (
	"fmt"

	"github.com/cznic/mathutil"
)

%}

%union {
	line int
	col  int
	item interface{}
	list []interface{}
}

%token	add alter and andand andnot as asc
	begin between bigIntType bigRatType blobType boolType by byteType
	column commit complex128Type complex64Type create
	deleteKwd desc distinct drop durationType
	eq exists
	falseKwd floatType float32Type float64Type floatLit from 
	ge group
	identifier ifKwd imaginaryLit in index insert intType int16Type
	int32Type int64Type int8Type into intLit is
	le limit lsh 
	neq not null
	offset on order oror
	qlParam
	rollback rsh runeType
	selectKwd set stringType stringLit
	tableKwd timeType transaction trueKwd truncate
	uintType uint16Type uint32Type uint64Type uint8Type unique update
	values
	where

%token	<item>
	floatLit imaginaryLit intLit stringLit

%token	<item>
	bigIntType bigRatType blobType boolType byteType
	complex64Type complex128Type
	durationType
	falseKwd floatType float32Type float64Type
	identifier intType int16Type int32Type int64Type int8Type 
	null
	qlParam
	runeType
	stringType
	timeType trueKwd
	uintType uint16Type uint32Type uint64Type uint8Type

%type	<item>
	AlterTableStmt Assignment AssignmentList AssignmentList1
	BeginTransactionStmt
	Call Call1 ColumnDef ColumnName ColumnNameList ColumnNameList1
	CommitStmt Conversion CreateIndexStmt CreateIndexIfNotExists
	CreateIndexStmtUnique CreateTableStmt CreateTableStmt1
	DeleteFromStmt DropIndexStmt DropIndexIfExists DropTableStmt
	EmptyStmt Expression ExpressionList ExpressionList1
	Factor Factor1 Field Field1 FieldList
	GroupByClause
	Index InsertIntoStmt InsertIntoStmt1 InsertIntoStmt2
	Literal
	Operand OrderBy OrderBy1
	QualifiedIdent
	PrimaryExpression PrimaryFactor PrimaryTerm
	RecordSet RecordSet1 RecordSet2 RollbackStmt
	SelectStmt SelectStmtDistinct SelectStmtFieldList SelectStmtLimit
	SelectStmtWhere SelectStmtGroup SelectStmtOffset SelectStmtOrder Slice
	Statement StatementList
	TableName Term TruncateTableStmt Type
	UnaryExpr UpdateStmt UpdateStmt1
	WhereClause

%type	<list>	RecordSetList

%start	StatementList

%%

AlterTableStmt:
	alter tableKwd TableName add ColumnDef
	{
		$$ = &alterTableAddStmt{tableName: $3.(string), c: $5.(*col)}
	}
|	alter tableKwd TableName drop column ColumnName
	{
		$$ = &alterTableDropColumnStmt{tableName: $3.(string), colName: $6.(string)}
	}

Assignment:
	ColumnName '=' Expression
	{
		$$ = assignment{colName: $1.(string), expr: $3.(expression)}
	}

AssignmentList:
	Assignment AssignmentList1 AssignmentList2
	{
		$$ = append([]assignment{$1.(assignment)}, $2.([]assignment)...)
	}

AssignmentList1:
	/* EMPTY */
	{
		$$ = []assignment{}
	}
|	AssignmentList1 ',' Assignment
	{
		$$ = append($1.([]assignment), $3.(assignment))
	}

AssignmentList2:
	/* EMPTY */
|	','

BeginTransactionStmt:
	begin transaction
	{
		$$ = beginTransactionStmt{}
	}

Call:
	'(' Call1 ')'
	{
		$$ = $2
	}

Call1:
	/* EMPTY */
	{
		$$ = []expression{}
	}
|	ExpressionList

ColumnDef:
	ColumnName Type
	{
		$$ = &col{name: $1.(string), typ: $2.(int)}
	}

ColumnName:
	identifier

ColumnNameList:
	ColumnName ColumnNameList1 ColumnNameList2
	{
		$$ = append([]string{$1.(string)}, $2.([]string)...)
	}

ColumnNameList1:
	/* EMPTY */
	{
		$$ = []string{}
	}
|	ColumnNameList1 ',' ColumnName
	{
		$$ = append($1.([]string), $3.(string))
	}

ColumnNameList2:
	/* EMPTY */
|	','

CommitStmt:
	commit
	{
		$$ = commitStmt{}
	}

Conversion:
	Type '(' Expression ')'
	{
		$$ = &conversion{typ: $1.(int), val: $3.(expression)}
	}

CreateIndexStmt:
	create CreateIndexStmtUnique index CreateIndexIfNotExists identifier on identifier '(' identifier ')'
	{
		indexName, tableName, columnName := $5.(string), $7.(string), $9.(string)
		$$ = &createIndexStmt{unique: $2.(bool), ifNotExists: $4.(bool), indexName: indexName, tableName: tableName, colName: columnName}
		if indexName == tableName || indexName == columnName {
			yylex.(*lexer).err("index name collision: %s", indexName)
			return 1
		}

		if isSystemName[indexName] || isSystemName[tableName] {
			yylex.(*lexer).err("name is used for system tables: %s", indexName)
			return 1
		}
	}
|	create CreateIndexStmtUnique index CreateIndexIfNotExists identifier on identifier '(' identifier '(' ')' ')'
	{
		indexName, tableName, columnName := $5.(string), $7.(string), $9.(string)
		$$ = &createIndexStmt{unique: $2.(bool), ifNotExists: $4.(bool), indexName: indexName, tableName: tableName, colName: "id()"}
		if $9.(string) != "id" {
			yylex.(*lexer).err("only the built-in function id() can be used in index: %s()", columnName)
			return 1
		}

		if indexName == tableName {
			yylex.(*lexer).err("index name collision: %s", indexName)
			return 1
		}

		if isSystemName[indexName] || isSystemName[tableName] {
			yylex.(*lexer).err("name is used for system tables: %s", indexName)
			return 1
		}
	}

CreateIndexIfNotExists:
	{
		$$ = false
	}
|	ifKwd not exists
	{
		$$ = true
	}

CreateIndexStmtUnique:
	{
		$$ = false
	}
|	unique
	{
		$$ = true
	}

CreateTableStmt:
	create tableKwd TableName '(' ColumnDef CreateTableStmt1 CreateTableStmt2 ')'
	{
		nm := $3.(string)
		$$ = &createTableStmt{tableName: nm, cols: append([]*col{$5.(*col)}, $6.([]*col)...)}
		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}
|	create tableKwd ifKwd not exists TableName '(' ColumnDef CreateTableStmt1 CreateTableStmt2 ')'
	{
		nm := $6.(string)
		$$ = &createTableStmt{ifNotExists: true, tableName: nm, cols: append([]*col{$8.(*col)}, $9.([]*col)...)}
		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}

CreateTableStmt1:
	/* EMPTY */
	{
		$$ = []*col{}
	}
|	CreateTableStmt1 ',' ColumnDef
	{
		$$ = append($1.([]*col), $3.(*col))
	}

CreateTableStmt2:
	/* EMPTY */
|	','

DeleteFromStmt:
	deleteKwd from TableName
	{
		$$ = &truncateTableStmt{$3.(string)}
	}
|	deleteKwd from TableName WhereClause
	{
		$$ = &deleteStmt{tableName: $3.(string), where: $4.(*whereRset).expr}
	}

DropIndexStmt:
	drop index DropIndexIfExists identifier
	{
		$$ = &dropIndexStmt{ifExists: $3.(bool), indexName: $4.(string)}
	}

DropIndexIfExists:
	{
		$$ = false
	}
|	ifKwd exists
	{
		$$ = true
	}

DropTableStmt:
	drop tableKwd TableName
	{
		nm := $3.(string)
		$$ = &dropTableStmt{tableName: nm}
		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}
|	drop tableKwd ifKwd exists TableName
	{
		nm := $5.(string)
		$$ = &dropTableStmt{ifExists: true, tableName: nm}
		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}

EmptyStmt:
	/* EMPTY */
	{
		$$ = nil
	}

Expression:
	Term
|	Expression oror Term
	{
		var err error
		if $$, err = newBinaryOperation(oror, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

ExpressionList:
	Expression ExpressionList1 ExpressionList2
	{
		$$ = append([]expression{$1.(expression)}, $2.([]expression)...)
	}

ExpressionList1:
	/* EMPTY */
	{
		$$ = []expression(nil)
	}
|	ExpressionList1 ',' Expression
	{
		$$ = append($1.([]expression), $3.(expression))
	}

ExpressionList2:
	/* EMPTY */
|	','

Factor:
	Factor1
|       Factor1 in '(' ExpressionList ')'
        {
		$$ = &pIn{expr: $1.(expression), list: $4.([]expression)}
        }
|       Factor1 not in '(' ExpressionList ')'
        {
		$$ = &pIn{expr: $1.(expression), not: true, list: $5.([]expression)}
        }
|       Factor1 between PrimaryFactor and PrimaryFactor
        {
		$$ = &pBetween{expr: $1.(expression), l: $3.(expression), h: $5.(expression)}
        }
|       Factor1 not between PrimaryFactor and PrimaryFactor
        {
		$$ = &pBetween{expr: $1.(expression), not: true, l: $4.(expression), h: $6.(expression)}
        }
|       Factor1 is null
        {
		$$ = &isNull{expr: $1.(expression)}
        }
|       Factor1 is not null
        {
		$$ = &isNull{expr: $1.(expression), not: true}
        }

Factor1:
        PrimaryFactor
|       Factor1 ge PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(ge, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 '>' PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation('>', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 le PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(le, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 '<' PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation('<', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 neq PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(neq, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 eq PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(eq, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }

Field:
	Expression Field1
	{
		expr, name := $1.(expression), $2.(string)
		if name == "" {
			s, ok := expr.(*ident)
			if ok {
				name = s.s
			}
		}
		$$ = &fld{expr: expr, name: name}
	}

Field1:
	/* EMPTY */
	{
		$$ = ""
	}
|	as identifier
	{
		$$ = $2
	}

FieldList:
	Field
	{
		$$ = []*fld{$1.(*fld)}
	}
|	FieldList ',' Field
	{
		l, f := $1.([]*fld), $3.(*fld)
		if f.name != "" {
			if f := findFld(l, f.name); f != nil {
				yylex.(*lexer).err("duplicate field name %q", f.name)
				return 1
			}
		}

		$$ = append($1.([]*fld), $3.(*fld))
	}

GroupByClause:
	group by ColumnNameList
	{
		$$ = &groupByRset{colNames: $3.([]string)}
	}

Index:
	'[' Expression ']'
	{
		$$ = $2
	}

InsertIntoStmt:
	insert into TableName InsertIntoStmt1 values '(' ExpressionList ')' InsertIntoStmt2 InsertIntoStmt3
	{
		$$ = &insertIntoStmt{tableName: $3.(string), colNames: $4.([]string), lists: append([][]expression{$7.([]expression)}, $9.([][]expression)...)}
	}
|	insert into TableName InsertIntoStmt1 SelectStmt
	{
		$$ = &insertIntoStmt{tableName: $3.(string), colNames: $4.([]string), sel: $5.(*selectStmt)}
	}

InsertIntoStmt1:
	/* EMPTY */
	{
		$$ = []string{}
	}
|	'(' ColumnNameList ')'
	{
		$$ = $2
	}

InsertIntoStmt2:
	/* EMPTY */
	{
		$$ = [][]expression{}
	}
|	InsertIntoStmt2 ',' '(' ExpressionList ')'
	{
		$$ = append($1.([][]expression), $4.([]expression))
	}

InsertIntoStmt3:
|      ','


Literal:
	falseKwd
|	null
|	trueKwd
|	floatLit
|	imaginaryLit
|	intLit
|	stringLit

Operand:
	Literal
	{
		$$ = value{$1}
	}
|	qlParam
	{
		n := $1.(int)
		$$ = parameter{n}
		l := yylex.(*lexer)
		l.params = mathutil.Max(l.params, n)
		if n == 0 {
			l.err("parameter number must be non zero")
			return 1
		}
	}
|	QualifiedIdent
	{
		$$ = &ident{$1.(string)}
	}
|	'(' Expression ')'
	{
		$$ = &pexpr{expr: $2.(expression)}
	}

OrderBy:
	order by ExpressionList OrderBy1
	{
		$$ = &orderByRset{by: $3.([]expression), asc: $4.(bool)}
	}

OrderBy1:
	/* EMPTY */
	{
		$$ = true // ASC by default
	}
|	asc
	{
		$$ = true
	}
|	desc
	{
		$$ = false
	}

PrimaryExpression:
	Operand
|	Conversion
|	PrimaryExpression Index
	{
		var err error
		if $$, err = newIndex($1.(expression), $2.(expression)); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryExpression Slice
	{
		var err error
		s := $2.([2]*expression)
		if $$, err = newSlice($1.(expression), s[0], s[1]); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryExpression Call
	{
		x := yylex.(*lexer)
		f, ok := $1.(*ident)
		if !ok {
			x.err("expected identifier or qualified identifier")
			return 1
		}

		var err error
		var agg bool
		if $$, agg, err = newCall(f.s, $2.([]expression)); err != nil {
			x.err("%v", err)
			return 1
		}
		if n := len(x.agg); n > 0 {
			x.agg[n-1] = x.agg[n-1] || agg
		}
	}

PrimaryFactor:
	PrimaryTerm
|	PrimaryFactor '^' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('^', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '|' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('|', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '-' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('-', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '+' PrimaryTerm
	{
		var err error
		$$, err = newBinaryOperation('+', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

PrimaryTerm:
	UnaryExpr
|	PrimaryTerm andnot UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(andnot, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '&' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('&', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm lsh UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(lsh, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm rsh UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(rsh, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '%' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('%', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '/' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('/', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '*' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('*', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

QualifiedIdent:
	identifier
|	identifier '.' identifier
	{
		$$ = fmt.Sprintf("%s.%s", $1.(string), $3.(string))
	}

RecordSet:
	RecordSet1 RecordSet2
	{
		$$ = []interface{}{$1, $2}
	}

RecordSet1:
	identifier
|	'(' SelectStmt RecordSet11 ')'
	{
		$$ = $2
	}

RecordSet11:
	/* EMPTY */
|	';'

RecordSet2:
	/* EMPTY */
	{
		$$ = ""
	}
|	as identifier
	{
		$$ = $2
	}

RecordSetList:
	RecordSet
	{
		$$ = []interface{}{$1}
	}
|	RecordSetList ',' RecordSet
	{
		$$ = append($1, $3)
	}

RollbackStmt:
	rollback
	{
		$$ = rollbackStmt{}
	}

SelectStmt:
	selectKwd SelectStmtDistinct SelectStmtFieldList from RecordSetList
	SelectStmtWhere SelectStmtGroup SelectStmtOrder SelectStmtLimit SelectStmtOffset
	{
		x := yylex.(*lexer)
		n := len(x.agg)
		$$ = &selectStmt{
			distinct:      $2.(bool),
			flds:          $3.([]*fld),
			from:          &crossJoinRset{sources: $5},
			hasAggregates: x.agg[n-1],
			where:         $6.(*whereRset),
			group:         $7.(*groupByRset),
			order:         $8.(*orderByRset),
			limit:         $9.(*limitRset),
			offset:        $10.(*offsetRset),
		}
		x.agg = x.agg[:n-1]
	}
|	selectKwd SelectStmtDistinct SelectStmtFieldList from RecordSetList ','
	SelectStmtWhere SelectStmtGroup SelectStmtOrder SelectStmtLimit SelectStmtOffset
	{
		x := yylex.(*lexer)
		n := len(x.agg)
		$$ = &selectStmt{
			distinct:      $2.(bool),
			flds:          $3.([]*fld),
			from:          &crossJoinRset{sources: $5},
			hasAggregates: x.agg[n-1],
			where:         $7.(*whereRset),
			group:         $8.(*groupByRset),
			order:         $9.(*orderByRset),
			limit:         $10.(*limitRset),
			offset:        $11.(*offsetRset),
		}
		x.agg = x.agg[:n-1]
	}

SelectStmtLimit:
	{
		$$ = (*limitRset)(nil)
	}
|	limit Expression
	{
		$$ = &limitRset{expr: $2.(expression)}
	}

SelectStmtOffset:
	{
		$$ = (*offsetRset)(nil)
	}
|	offset Expression
	{
		$$ = &offsetRset{expr: $2.(expression)}
	}

SelectStmtDistinct:
	/* EMPTY */
	{
		$$ = false
	}
|	distinct
	{
		$$ = true
	}

SelectStmtFieldList:
	'*'
	{
		$$ = []*fld{}
	}
|	FieldList
	{
		$$ = $1
	}
|	FieldList ','
	{
		$$ = $1
	}

SelectStmtWhere:
	/* EMPTY */
	{
		$$ = (*whereRset)(nil)
	}
|	WhereClause

SelectStmtGroup:
	/* EMPTY */
	{
		$$ = (*groupByRset)(nil)
	}
|	GroupByClause

SelectStmtOrder:
	/* EMPTY */
	{
		$$ = (*orderByRset)(nil)
	}
|	OrderBy

Slice:
	'[' ':' ']'
	{
		$$ = [2]*expression{nil, nil}
	}
|	'[' ':' Expression ']'
	{
		hi := $3.(expression)
		$$ = [2]*expression{nil, &hi}
	}
|	'[' Expression ':' ']'
	{
		lo := $2.(expression)
		$$ = [2]*expression{&lo, nil}
	}
|	'[' Expression ':' Expression ']'
	{
		lo := $2.(expression)
		hi := $4.(expression)
		$$ = [2]*expression{&lo, &hi}
	}

Statement:
	EmptyStmt
|	AlterTableStmt
|	BeginTransactionStmt
|	CommitStmt
|	CreateIndexStmt
|	CreateTableStmt
|	DeleteFromStmt
|	DropIndexStmt
|	DropTableStmt
|	InsertIntoStmt
|	RollbackStmt
|	SelectStmt
|	TruncateTableStmt
|	UpdateStmt

StatementList:
	Statement
	{
		if $1 != nil {
			yylex.(*lexer).list = []stmt{$1.(stmt)}
		}
	}
|	StatementList ';' Statement
	{
		if $3 != nil {
			yylex.(*lexer).list = append(yylex.(*lexer).list, $3.(stmt))
		}
	}

TableName:
	identifier

Term:
	Factor
|	Term andand Factor
	{
		var err error
		if $$, err = newBinaryOperation(andand, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

TruncateTableStmt:
	truncate tableKwd TableName
	{
		$$ = &truncateTableStmt{tableName: $3.(string)}
	}

Type:
	bigIntType
|	bigRatType
|	blobType
|	boolType
|	byteType
|	complex128Type
|	complex64Type
|	durationType
|	floatType
|	float32Type
|	float64Type
|	intType
|	int16Type
|	int32Type
|	int64Type
|	int8Type
|	runeType
|	stringType
|	timeType
|	uintType
|	uint16Type
|	uint32Type
|	uint64Type
|	uint8Type

UpdateStmt:
	update TableName oSet AssignmentList UpdateStmt1
	{
		$$ = &updateStmt{tableName: $2.(string), list: $4.([]assignment), where: $5.(*whereRset).expr}
	}

UpdateStmt1:
	/* EMPTY */
	{
		$$ = nowhere
	}
|	WhereClause

UnaryExpr:
	PrimaryExpression
|	'^'  PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('^', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'!' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('!', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'-' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('-', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'+' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('+', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

WhereClause:
	where Expression
	{
		$$ = &whereRset{expr: $2.(expression)}
	}


oSet:
|	set
