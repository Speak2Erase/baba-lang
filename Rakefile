desc "Generate parser"
task :parser do
  `racc lib/keke_parser.ry -o lib/keke/parser.rb`
end

desc "Generate lexer"
task :lexer do
  `rex lib/keke_lexer.rex -o lib/keke/lexer.rb`
end

desc "Generate"
task :generate => [:parser, :lexer]

task default: :generate
