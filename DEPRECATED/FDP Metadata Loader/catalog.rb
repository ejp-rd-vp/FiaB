class DCATCatalog < DCATResource
    attr_accessor :primaryTopic
    #attr_accessor :type
    attr_accessor :themeTaxonomy
    attr_accessor :dataset
    
    # def initialize(primary_topic: nil, baseuri: "http://example.org", access_rights: nil, conforms_to: nil, contact_point: nil, resource_creator: nil, 
    #     title: nil, release_date: nil, modification_date: nil, publisher: nil, identifier: nil, license: nil  )
    def initialize( themeTaxonomy: nil, **args)
        super
        @dataset = nil
        @themeTaxonomy = themeTaxonomy
        $stderr.puts self.inspect
        self.types = [DCAT.Catalog, DCAT.Resource]
        init_catalog()   # create record and get GUID
        self.build  # make the RDF
        write_catalog()

    end
    
    def init_catalog()
        $stderr.puts "initializing catalog"
        catinit = <<END
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

<> a dcat:Catalog, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dct:isPartOf <#{self.parentURI}> .            
END

        $stderr.puts "#{self.serverURL}/catalog"
#        $stderr.puts catinit
        resp = RestClient.post("#{self.serverURL}/catalog", catinit, $headers)
        catlocation = resp.headers[:location]
        puts "temporary catalog written to #{catlocation}\n\n"
        self.identifier = RDF::URI(catlocation)  # set identifier to where it lives
    end

    def write_catalog()
        self.build()
        location = self.identifier.to_s.gsub(self.baseURI, self.serverURL)
        $stderr.puts "rewriting cat to #{location}"
        catalog = self.serialize
        $stderr.puts catalog
        resp = RestClient.put(location, catalog, $headers)
        $stderr.puts resp.headers.to_s

    end



end

