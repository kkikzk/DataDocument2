class DocParser
  token IDENT
	token NUMBER
	token STRING

rule
  document: { result = ParseResult.new() }
  	| document enum { val[0].addEnum(val[1]); result = val[0] }
		| document struct { val[0].addStruct(val[1]); result = val[0] }

	enum: attributes 'enum' IDENT '{' enum_decl '}'
	  { result = EnumData.new(val[2], val[0], val[4]) }

  enum_decl: each_enum_decl { result = [val[0]] }
  	| enum_decl ',' each_enum_decl { val[0].push(val[2]); result = val[0] }

	each_enum_decl: attributes IDENT '=' NUMBER
	  { result = EnumElement.new(val[1], val[0], val[3]) }

  attributes: { result = [] }
	  | attributes '[' attribute_decl ']' { result = val[0] + val[2] }

	attribute_decl: each_attribute_decl { result = [val[0]] }
	  | attribute_decl ',' each_attribute_decl { val[0].push(val[2]); result = val[0] }

	each_attribute_decl: IDENT '(' STRING ')' { result = Attribute.new(val[0], val[2]) }
	  | IDENT '(' ')' { result = Attribute.new(val[0], '') }

	struct: attributes 'struct' IDENT base_type_decl '{' struct_element_decl '}'
	  { result = StructData.new(val[2], val[0], val[3], val[5]) }

	base_type_decl: { result = nil }
		| ':' IDENT { result = val[1] }

	struct_element_decl: each_struct_element_decl { result = [val[0]] }
	  | struct_element_decl each_struct_element_decl { val[0].push(val[1]); result = val[0] }

	each_struct_element_decl: attributes type_decl IDENT condition_decl array_decl default_value_decl ';'
	  { result = StructElement.new(val[2], val[0], val[1], val[3], val[4], val[5]) }
		| attributes unnamed_struct IDENT array_decl ';'
		{ result = StructElement.new(val[2], val[0], val[1], nil, val[3], nil) }

	type_decl: 'int64' { result = val[0] }
	  | 'int32' { result = val[0] }
		| 'int16' { result = val[0] }
		| 'int8' { result = val[0] }
		| 'uint64' { result = val[0] }
		| 'uint32' { result = val[0] }
		| 'uint16' { result = val[0] }
		| 'uint8' { result = val[0] }
		| 'bool' { result = val[0] }
		| 'string' { result = val[0] }
		| 'decimal' { result = val[0] }
		| 'float' { result = val[0] }
		| 'double' { result = val[0] }
		| 'char' { result = val[0] }
		| IDENT { result = val[0] }

	unnamed_struct: 'struct' '{' struct_element_decl '}'
	  { result = StructData.new('unnamed_struct', [], nil, val[2]) }

  condition_decl: { result = nil }
	  | '(' condition_decls ')' { result = val[1] }

	condition_decls: each_condition_decl { result = [val[0]] }
		| condition_decls ',' each_condition_decl { val[0].push(val[2]); result = val[0] }

	each_condition_decl: NUMBER '..' NUMBER { result = val[0].to_s + '..' + val[2].to_s }
	  | NUMBER '..' { result = val[0].to_s + '..Max' }
		| '..' NUMBER { result = 'Min..' + val[1].to_s }
		| NUMBER { result = val[0].to_s + '..' + val[0].to_s }

	array_decl: { result = 1 }
		| '[' ']' { result = -1 }
		| '[' NUMBER ']' { result = val[1] }

	default_value_decl: { result = nil }
	  | '=' NUMBER { result = val[1] }
	  | '=' STRING { result = val[1] }

---- header
require './Scanner'
require './ParseResult'
include DataDocument

---- inner
def parse(str)
  keywords = [
	  'enum',
		'struct',
		'unnamed_struct',
		'int64',
		'int32',
		'int16',
		'int8',
		'uint64',
		'uint32',
		'uint16',
		'uint8',
		'bool',
		'string',
		'decimal',
		'float',
		'double',
		'char',
		'double'
	]
	symbols = [
	  ',',
		';',
		'=',
		'..',
		':',
		'{',
		'}',
		'(',
		')',
		'[',
		']'
	]
  @sc = Scanner.new(keywords, symbols)
	@sc.parse(str)
  do_parse()
end

def next_token
  @sc.popToken
end