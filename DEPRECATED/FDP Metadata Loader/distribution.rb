class DCATDistribution < DCATResource
    attr_accessor :was_generated_by, :mediaType, :format
    
    def initialize(was_generated_by: nil, mediaType:  nil, format: nil,  **args )
        @was_generated_by = was_generated_by
        @mediaType = mediaType
        @format = format
        super 

        self.types = [DCAT.Distribution, DCAT.Distribution]
        init_distribution()   # create record and get GUID
        self.build  # make the RDF
        write_distribution()

    end
    
    def init_distribution()
        $stderr.puts "initializing distribution"
        distinit = <<END
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
<> a dcat:Distribution, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dct:isPartOf <#{self.parentURI}> ;
    dcat:mediaType "application/sparql-results+json" .

END

        $stderr.puts "#{self.serverURL}/distribution"
        $stderr.puts distinit
        resp = RestClient.post("#{self.serverURL}/distribution", distinit, $headers)
        distlocation = resp.headers[:location]
        puts "temporary distribution written to #{distlocation}\n\n"
        self.identifier = RDF::URI(distlocation)  # set identifier to where it lives
    end

    def write_distribution()
        self.build
        location = self.identifier.to_s.gsub(self.baseURI, self.serverURL)
        $stderr.puts "rewriting distribution to #{location}"
        distribution = self.serialize
        $stderr.puts distribution
        resp = RestClient.put(location, distribution, $headers)
        $stderr.puts resp.headers.to_s

    end

   

end

