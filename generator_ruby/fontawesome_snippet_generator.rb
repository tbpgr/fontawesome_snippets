require 'open-uri'
require 'nokogiri'
require 'erb'

module FontAwesome
  module SublimeText
    URL = 'http://fortawesome.github.io/Font-Awesome/icons/'
    OUTPUT_DIR = 'fontawesome_snippets'
    OUTPUT_SAMPLE_DIR = 'fontawesome_samples'

    class Generator
      def self.bulk_output(klasses)
        Dir.mkdir(OUTPUT_SAMPLE_DIR) unless Dir.exist?(OUTPUT_SAMPLE_DIR)
        sample_html = apply_sample_html(klasses)
        output_sample_html(sample_html)

        Dir.mkdir(OUTPUT_DIR) unless Dir.exist?(OUTPUT_DIR)
        klasses.each do |klass|
          generator = Generator.new(klass)
          snippet = generator.apply_snippet
          generator.output_snippets(OUTPUT_DIR, snippet)
        end
      end

      def self.apply_sample_html(klasses)
        samples = klasses.map do |klass|
          format("<tr><td><i class='fa %s' style='font-size:3em;'></i></td><td>%s</td></tr>", klass, klass)
        end.join("\n")

        template =<<-EOS
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>Font Awesome Samples</title>
  <link href='http://fonts.googleapis.com/css?family=Crete+Round' rel='stylesheet' type='text/css'>
  <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
  <style type="text/css">
  body {
    font-family: Crete Round, Arial, serif;
  }
  h1  {
    width: 400px;
    margin: 0 auto;
  }
  table {
    width: 400px;
    margin: 0 auto;
  }
  td {
    text-align:left;
  }
  </style>
</head>
<body>
  <h1>Font Awesome Samples</h1>
  <hr>
  <table>
  <%=samples%>
  </table>
</body>
</html>
        EOS
        ERB.new(template).result(binding)
      end

      def self.output_sample_html(sample_html)
        File.open("./#{OUTPUT_SAMPLE_DIR}/fontawesome_samples.html", "w:utf-8") do |e|
          e.puts(sample_html)
        end
      end

      def initialize(klass)
        @klass = klass
      end

      def apply_snippet
        klass = @klass
        template =<<-EOS
<snippet>
  <content><![CDATA[
<i class="fa <%=klass%>" style="font-size:1em;"></i>
]]></content>
  <tabTrigger><%=klass%></tabTrigger>
  <scope>text.html.markdown</scope>
  <description>fontawesome fa <%=klass%></description>
</snippet>
        EOS
        ERB.new(template).result(binding)
      end

      def output_snippets(output_dir, snippet)
        File.open("./#{output_dir}/#{@klass}.sublime-snippet", "w:utf-8") do |e|
          e.puts(snippet)
        end
      end
    end
  end
end

charset = nil
html = open(FontAwesome::SublimeText::URL) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)
klasses = doc.xpath('//i[contains(@class,"fa")]')
   .map { |e|e.attributes.first.last.value }
   .map { |e|e.split(' ') }
   .select { |e|e.size === 2 }
   .map { |e|e[1] }
   .to_a
   .uniq
   .sort

FontAwesome::SublimeText::Generator.bulk_output(klasses)
