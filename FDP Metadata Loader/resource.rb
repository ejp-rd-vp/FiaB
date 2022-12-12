
require 'linkeddata'
require 'rest-client'

DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
BS = RDF::Vocabulary.new("http://rdf.biosemantics.org/ontologies/fdp-o#")

class DCATResource
    attr_accessor :baseURI
    attr_accessor :parentURI, :serverURL
    attr_accessor :accessRights, :conformsTo, :contactName, :contactEmail, :creator, :creatorName
    attr_accessor :title, :description, :issued, :modified, :hasVersion
    attr_accessor :publisher,:identifier, :license, :language
    attr_accessor :dataset,:keyword,:landingPage,:qualifiedRelation,:theme,:service,:themeTaxonomy,:homepage 
    attr_accessor :types
    attr_accessor :g  # the graph


    def initialize(types: [DCAT.Resource], baseURI: nil, parentURI: nil, 
        accessRights: nil, conformsTo: nil, contactEmail: nil,contactName: nil, creator: nil, creatorName: nil, 
        title: nil, description: nil, issued: nil, modified: nil, hasVersion: nil, publisher: nil, 
        identifier: nil, license: nil, language: "http://id.loc.gov/vocabulary/iso639-1/en", 
        dataset: nil, keyword: nil, landingPage: nil, qualifiedRelation: nil, theme: nil,
        service: nil, themeTaxonomy: nil, homepage: nil, serverURL: "http://localhost:7070",
        **args )

        @accessRights = accessRights
        @conformsTo = conformsTo
        @contactName = contactName
        @contactEmail = contactEmail
        @creator = creator
        @creatorName = creatorName
        @title = title
        @description = description
        @issued = issued
        @modified = modified
        @hasVersion = hasVersion
        @publisher = publisher
        @identifier = identifier
        @license = license
        @language = language

        @dataset = dataset
        @keyword = keyword
        @landingPage = landingPage
        @qualifiedRelation = qualifiedRelation
        @theme = theme
        @service = service
        @themeTaxonomy = themeTaxonomy
        @homepage = homepage

        @serverURL = RDF::URI(serverURL)
        @baseURI = RDF::URI(baseURI)
        @parentURI = RDF::URI(parentURI)
        @types = types

        abort "you must set baseURI and serverURL parameters" unless (self.baseURI and self.serverURL)

        set_headers()
    end
    
    def set_headers
        return if $headers
        puts ENV['FDPUSER']
        puts ENV['FDPPASS'] 
        payload = '{ "email": "' + ENV['FDPUSER'] + '", "password": "' + ENV['FDPPASS'] + '" }'
        resp = RestClient.post("#{self.serverURL}/tokens", payload, headers={content_type: 'application/json'})    
        $token = JSON.parse(resp.body)["token"]
        puts $token
        $headers = {content_type: 'text/turtle', authorization: "Bearer #{$token}", accept: "text/turtle"}


    end
    def build()
        @g = RDF::Graph.new()  # reset graph
        abort "an identifier has not been set" unless self.identifier
        self.types.each do |type|
            self.g << [self.identifier, RDF.type, type]
        end
        
        self.g << [self.identifier, RDF::Vocab::RDFS.label, @title] if @title
        self.g << [self.identifier, RDF::Vocab::DC.isPartOf, @parentURI] if @parentURI

        #DCAT
        %w[keyword landingPage qualifiedRelation service themeTaxonomy].each do |f|
            (pred, value) = get_pred_value(f, "DCAT")
            next unless pred and value
            self.g << [self.identifier, pred, value]
        end

        #DCT
        %w[accessRights hasVersion conformsTo title description identifier license language creator].each do |f|
            (pred, value) = get_pred_value(f, "DCT")
            next unless pred and value
            self.g << [self.identifier, pred, value]
        end
        %w[issued modified].each do |f|
            $stderr.puts "doing issued modified #{f}"
            (pred, value) = get_pred_value(f, "DCT", "TIME")
            next unless pred and value
            self.g << [self.identifier, pred, value]
            self.g << [self.identifier, BS.issued, value]
            self.g << [self.identifier, BS.modified, value]
            
        end

        #FOAF
        %w[homepage].each do |f|
            (pred, value) = get_pred_value(f, "FOAF")
            next unless pred and value
            self.g << [self.identifier, pred, value]
        end

        # COMPLEX

        #identifier 
        # contactPoint
        if self.contactEmail or self.contactName
            bnode = RDF::URI.new(self.identifier.to_s + "#contact")
            self.g << [self.identifier, DCAT.contactPoint, bnode]
            self.g << [bnode, RDF.type, RDF::URI.new("http://www.w3.org/2006/vcard/ns#Individual")]
            self.g << [bnode, RDF::URI.new("http://www.w3.org/2006/vcard/ns#fn"), self.contactName] if self.contactName
            self.g << [bnode, RDF::URI.new("http://www.w3.org/2006/vcard/ns#hasEmail"), self.contactEmail] if self.contactEmail
        end
            
        #publisher
        if self.publisher
            bnode = RDF::Node.new()
            self.g << [self.identifier, RDF::Vocab::DC.publisher, bnode]
            self.g << [bnode, RDF.type, FOAF.Agent]
            self.g << [bnode, FOAF.name, self.publisher]
        end
  
        #creator
        if self.creator
            self.g << [self.identifier, RDF::Vocab::DC.creator, RDF::URI.new(self.creator)]
            self.g << [RDF::URI.new(self.creator), RDF.type, FOAF.Agent]
            self.g << [RDF::URI.new(self.creator), FOAF.name, self.creatorName]
        end

        #accessRights
        if self.accessRights
            self.g << [self.identifier, RDF::Vocab::DC.accessRights, RDF::URI.new(self.accessRights)]
            self.g << [RDF::URI.new(self.accessRights), RDF.type, RDF::Vocab::DC.RightsStatement]
        end

        #dataService
        if self.is_a? DCATDataService
            $stderr.puts "serializing data service #{self.endpointDescription} or #{self.endpointURL}"
            if self.endpointDescription or self.endpointURL 
                $stderr.puts "serializing ENDPOINTS"
                bnode = RDF::Node.new()
                self.g << [self.identifier, DCAT.accessService, bnode]
                self.g << [bnode, RDF.type, DCAT.dataService]
                self.g << [bnode, DCAT.endpointDescription, RDF::URI.new(self.endpointDescription)] if self.endpointDescription
                self.g << [bnode, DCAT.endpointURL, RDF::URI.new(self.endpointURL)] if self.endpointURL
            end
        end

        #mediaType or format  https://www.iana.org/assignments/media-types/application/3gppHalForms+json
        if self.is_a? DCATDistribution
            if self.mediaType 
                # CHANGE THIS BACK WHEN FDP SHACL validation is correct
                # type = "https://www.iana.org/assignments/media-types/" + self.mediaType
                # type = RDF::URI.new(type)
                type = self.mediaType
                self.g << [self.identifier, DCAT.mediaType, type]
                # CHANGE THIS BACK ALSO!
                #self.g << [type, RDF.type, RDF::Vocab::DC.MediaType]
            end
            if self.format
                type = RDF::URI.new(self.format)
                self.g << [self.identifier, RDF::Vocab::DC.format, type]
                self.g << [type, RDF.type, RDF::Vocab::DC.MediaTypeOrExtent]
            end
            # conformsTo
            if self.conformsTo
                schema = RDF::URI.new(self.conformsTo)
                self.g << [self.identifier, RDF::Vocab::DC.conformsTo, schema]
                self.g << [schema, RDF.type, RDF::Vocab::DC.Standard]
            end

        end

        # dataset  disgtribution
        if self.is_a? DCATCatalog and self.dataset
            self.g << [self.identifier, DCAT.dataset, RDF::URI.new(self.dataset)]
        elsif self.is_a? DCATDataset and self.distribution
            self.g << [self.identifier, DCAT.distribution, RDF::URI.new(self.distribution)]
        end


        # theme
        if self.theme
            themes = self.theme.split(",").filter_map{|url| url.strip if !url.strip.empty?}
            themes.each do |theme|
                self.g << [self.identifier, DCAT.theme, RDF::URI.new(theme)]
                self.g << [RDF::URI.new(theme), RDF.type, RDF::Vocab::SKOS.Concept]
                self.g << [RDF::URI.new(theme), RDF::Vocab::SKOS.inScheme, RDF::URI.new(self.identifier.to_s + "#conceptscheme")]
            end
            self.g << [ RDF::URI.new(self.identifier.to_s + "#conceptscheme"),  RDF.type, RDF::Vocab::SKOS.ConceptScheme]

        end

    end

    def serialize(format: :turtle)
        return @g.dump(:turtle)
    end

    def publish
        location = self.identifier.to_s.gsub(self.baseURI, self.serverURL)

        resp = RestClient.put("#{location}/meta/state", '{ "current": "PUBLISHED" }', headers={authorization: "Bearer #{$token}",  content_type: 'application/json'})        
        $stderr.puts "piublish response message"
        $stderr.puts resp.inspect
    end

    def get_pred_value(pred, vocab, datatype = nil)
        #$stderr.puts "getting #{pred}, #{vocab}"
        urire = Regexp.new("((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,8}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)")
        sym = '@'+pred
        #$stderr.puts "getting #{pred}, #{sym}..."
        case vocab
        when "DCT"
            pred = RDF::Vocab::DC[pred]
        when "DCAT"
            pred = DCAT[pred]
        when "FOAF"
            pred = FOAF[pred]
        end
        #$stderr.puts "got #{pred}, #{vocab}"

        value = self.instance_variable_get(sym).to_s
        thisvalue = value # temp compy
        #$stderr.puts "got2 #{pred}, #{value}"
        
        if datatype == "TIME"
            now = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
            value = RDF::Literal.new(thisvalue, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime"))
            $stderr.puts "time value1 #{value}"
            if !(value.valid?)
                thisvalue = thisvalue + "T12:00+01:00"  # make a guess that they only provided the date
                value = RDF::Literal.new(thisvalue, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime"))
                $stderr.puts "time value2 #{value}"
                if !(value.valid?)
                    value = RDF::Literal.new(now, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime"))
                    $stderr.puts "time value3 #{value}"
                end
            end                
        elsif urire.match(thisvalue)
            value = RDF::URI.new(thisvalue)
        end
        return [nil,nil] unless !value.to_s.empty?
        $stderr.puts "returning #{pred}, #{value}"
        return [pred, value]
    end

end


# %w() array of strings
# %r() regular expression.
# %q() string
# %x() a shell command (returning the output string)
# %i() array of symbols (Ruby >= 2.0.0)
# %s() symbol
# %() (without letter) shortcut for %Q()
