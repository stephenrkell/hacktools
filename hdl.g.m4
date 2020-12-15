include(head.g.m4)

antlr_m4_begin_rules

/* based on the antlr example at http://www.antlr.org/wiki/display/ANTLR3/Example */

INT :   ('1'..'9''0'..'9'*)|'0''x'('0'..'9'|'a'..'f'|'A'..'F')+|'0';
NEWLINE:'\r'? '\n' {antlr_m4_newline_action} ;
WS  :   (' '|'\t')+ {antlr_m4_skip_action} ;
LINECOMMENT : '/' '/'( ~ '\n' )* {antlr_m4_skip_action} ;
BLOCKCOMMENT : '/' '*' ( ~ '/' | ( ~ '*' ) '/' )* '*' '/' {antlr_m4_skip_action} ;
IDENT : ('a'..'z'|'A'..'Z'|'_'+'a'..'z'|'_'+'A'..'Z'|'_'+'0'..'9')('a'..'z'|'A'..'Z'|'0'..'9'|'_'|'\\'.)*;

toplevel : 'CHIP' IDENT '{' chipInterface chipDefinition '}'
    ;

chipInterface : chipInterfaceElement*
              ;

chipInterfaceElement : ( 'IN' | 'OUT' ) pinDecl ( ',' pinDecl )* ';'
                     ;

pinDecl : IDENT ( '[' INT ']' )?
        ;

chipDefinition : chipDefinitionElement*
               ;

chipDefinitionElement : 'PARTS' ':' partsList
                      | 'BUILTIN' IDENT ';'
                      | 'CLOCKED' pinList ';'
                      ;

pinList : IDENT (',' IDENT )*
        ;

partsList : partInstance*
          ;

partInstance : IDENT '(' pinAssignmentList ')' ';'
             ;

pinAssignmentList : pinAssignment ( ',' pinAssignment)*
                  ;

pinAssignment : pinSpec '=' pinSpec
              ;

pinSpec       : IDENT ( '[' INT  ( '..' INT )?  ']' )?
              ;
