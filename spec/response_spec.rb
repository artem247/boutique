require 'rspec'
require_relative '../routes/response' # Replace with the correct path to your Response class

RSpec.describe Response do
  context '#write' do
    it 'writes to an initially empty body' do
      response = Response.new
      response.write("Hello World")
      expect(response.body).to eq("Hello World")
    end

    it 'appends to an existing string body' do
      response = Response.new(body: "Hello")
      response.write(" World")
      expect(response.body).to eq("Hello World")
    end

    it 'handles an initial array body and appends to it' do
      response = Response.new(body: ["Hello", " "])
      response.write("World")
      expect(response.body).to eq("Hello World")
    end
    end
end

RSpec.describe Response do
  context '#set_headers' do
    it 'sets multiple headers correctly' do
      response = Response.new
      response.set_headers({'content-type' => 'application/json', 'X-Custom-Header' => 'CustomValue'})
      
      expect(response.headers['content-type']).to eq('application/json')
      expect(response.headers['X-Custom-Header']).to eq('CustomValue')
    end
  end
end

RSpec.describe Response do
    context 'Response helpers' do
      it 'correctly sets up a JSON response' do
        response = Response.new
        data = { message: 'Hello' }
        response.json(data)
  
        expect(response.status).to eq(200)
        expect(response.headers['content-type']).to eq('application/json')
        expect(response.body).to eq(data.to_json)
      end
  
      it 'correctly sets up an HTML response' do
        response = Response.new
        html_content = '<h1>Hello World</h1>'
        response.html(html_content)
  
        expect(response.status).to eq(200)
        expect(response.headers['content-type']).to eq('text/html')
        expect(response.body).to eq(html_content)
      end
    end
  end

  RSpec.describe Response do
    context '#finish' do
      it 'wraps non-array bodies in an array' do
        response = Response.new(body: "Hello")
        response.finish
        expect(response.body).to be_an(Array)
        expect(response.body).to eq(["Hello"])
      end
  
      it 'does not wrap array of strings' do
        response = Response.new(body: ["Hello", " ", "World"])
        response.finish
        expect(response.body).to eq(["Hello", " ", "World"])
      end
  
      it 'wraps mixed-type arrays' do
        response = Response.new(body: ["Hello", 123])
        response.finish
        expect(response.body).to eq([["Hello", 123]])
      end
    end
  end

  RSpec.describe Response do
    context '#finish' do
      it 'calculates content length correctly for string body' do
        response = Response.new(body: "Hello World")
        response.finish
        expect(response.headers['Content-Length']).to eq("11")
      end
  
      it 'calculates content length correctly for array body' do
        response = Response.new(body: ["Hello", " ", "World"])
        response.finish
        expect(response.headers['Content-Length']).to eq("11")
      end
    end
  end

  RSpec.describe Response do
    context 'performance metrics' do
      it 'logs response time and content length' do
        response = Response.new(body: "Hello World")
        expect { response.finish }.to output(/Performance Metrics: Response Time = \d+(\.\d+)? seconds, Content Length = 11 bytes/).to_stdout
      end
    end
  end
