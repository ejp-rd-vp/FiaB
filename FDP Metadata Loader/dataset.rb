class DCATDataset < DCATResource
    attr_accessor :was_generated_by
    attr_accessor :distribution, :theme, :landingPage
    
    def initialize(theme: nil, landingPage: nil,  **args)
        super 
        @theme = theme
        @landingPage = landingPage

        self.types = [DCAT.Resource, DCAT.Dataset]

        init_dataset()   # create record and get GUID
        self.build  # make the RDF
        write_dataset()

    end
    
    def init_dataset()
        $stderr.puts "initializing dataset"
        dsetinit = <<END
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
<> a dcat:Dataset, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dcat:theme <http://exampletheme.org/> ;
    dct:isPartOf <#{self.parentURI}> .
END

        $stderr.puts "#{self.serverURL}/dataset"
        $stderr.puts dsetinit
        resp = RestClient.post("#{self.serverURL}/dataset", dsetinit, $headers)
        dsetlocation = resp.headers[:location]
        puts "temporary dataset written to #{dsetlocation}\n\n"
        self.identifier = RDF::URI(dsetlocation)  # set identifier to where it lives
    end

    def write_dataset()
        self.build
        location = self.identifier.to_s.gsub(self.baseURI, self.serverURL)
        $stderr.puts "rewriting dset to #{location}"
        dataset = self.serialize
        $stderr.puts dataset
        resp = RestClient.put(location, dataset, $headers)
        $stderr.puts resp.headers.to_s

    end


end

