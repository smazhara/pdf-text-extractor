require 'sinatra'
require 'open-uri'

raise 'pdftotext not found' if `pdftotext 2>&1` !~ /pdftotext version/

set :haml, :format => :html5
set :show_exceptions, false
set :raise_errors, false

class ConversionError < RuntimeError
end

text=''
error ConversionError do
  "Cannot extract text from pdf because '#{text}'"
end

error OpenURI::HTTPError do
  "Cannot fetch pdf because '#{request.env['sinatra.error'].message}"
end

get '/' do
  haml :index
end

get '/pdf2txt' do
  pdf = open(params[:url])
  text = `pdftotext '#{pdf.path}' - 2>&1`
  pdf.close!
  raise ConversionError, text unless $?.success?
  text
end

__END__
@@ index

!!!
%html
  %head
    %title pdf text extractor..
    %script(src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js")
    :javascript
      $(function() {
        $('#pdf').submit(function() {
          var url = $('#pdf input').val();
          $.get('/pdf2txt', {url: url})
            .success(function(text) {
              $('#text').text(text);
            })
            .error(function(xhr, status, error) {
            alert(xhr.responseText);
            });
          return false;
        });
      });
    %style
      :sass
        input
          width: 50ex
  %body
    %form#pdf
      %label(for="url") url
      %input#url(value='http://localhost:4567/jquery.pdf')
    %fieldset
      %legend Extracted text
      %pre#text


