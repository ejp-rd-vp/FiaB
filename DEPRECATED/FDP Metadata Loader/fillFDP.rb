require './resource.rb'
require './catalog.rb'
require './dataset.rb'
require './distribution.rb'
require './access_service.rb'
require 'esv'

excel = ENV['EXCEL']
server = ENV['SERVER']
baseURI = ENV['BASE_URI']

excel = "example.xls" unless excel
server = "http://localhost:7070" unless server
baseURI = "http://localhost:7070" unless baseURI

data = File.read(excel)
data = ESV.parse(data)

data = data.filter_map {|d| [d[0], d[1]] if d[0]}
hash = Hash[*data.flatten]

#puts hash.inspect

catalog = DCATCatalog.new(
    serverURL: server,
    baseURI: baseURI,
    title: hash['cat_title'],  
    description: hash['cat_description'],
    hasVersion: hash['cat_hasVersion'],
    issued: hash['cat_issued'], 
    modified: hash['cat_modified'],
    publisher: hash['cat_publisher'], 
    license:hash['cat_license'], 
    accessRights: hash['cat_accessRights'], 
    creator:  hash['cat_creator'],
    creatorName:  hash['cat_creatorName'],
    contactEmail:  hash['cat_contactEmail'], 
    contactName:  hash['cat_contactName'],  
    parentURI: "http://localhost:7070",
)
#identifier = catalog.identifier.to_s

parentURI = catalog.identifier

dataset = DCATDataset.new(
    serverURL: server,
    baseURI: baseURI,
    title: hash['dset_title'],  
    description: hash['dset_description'],
    hasVersion: hash['dset_hasVersion'],
    issued: hash['dset_issued'], 
    modified: hash['dset_modified'],
    publisher: hash['dset_publisher'], 
    license:hash['dset_license'], 
    accessRights: hash['dset_accessRights'], 
    creator:  hash['dset_creator'],
    creatorName:  hash['dset_creatorName'],
    contactEmail:  hash['dset_contactEmail'], 
    contactName:  hash['dset_contactName'],
    landingPage: hash['dset_landingPage'],
    theme: hash['dset_theme'],
    parentURI: parentURI,
)
catalog.dataset= dataset.identifier.to_s
if hash['dset_theme']
    catalog.themeTaxonomy = dataset.identifier.to_s + "#conceptscheme"
end
catalog.write_catalog

parentURI = dataset.identifier
distribution = nil
if hash['dist_endpointURL'] or hash['dist_endpointDescription'] 
    $stderr.puts "starting to create dataservice"
    distribution = DCATDataService.new(
        serverURL: server,
        baseURI: baseURI,
        title: hash['dist_title'],
        description: hash['dist_description'],
        hasVersion: hash['dist_hasVersion'],
        issued: hash['dist_issued'],
        modified: hash['dist_modified'],
        publisher: hash['dist_publisher'],
        creator: hash['dist_creator'],
        creatorName: hash['dist_creatorName'],
        contactName: hash['dist_contactName'],
        contactEmail: hash['dist_contactEmail'],
        conformsTo: hash['dist_conformsTo'],
        license: hash['dist_license'],
        accessRights: hash[' dist_accessRights'],
        dist_downloadURL: hash['dist_downloadURL'],
        mediaType: hash['dist_mediaType'],
        format: hash['dist_format'],
        endpointDescription: hash['dist_endpointDescription'],
        endpointURL: hash['dist_endpointURL'],
        parentURI: parentURI
    )
    
else
    $stderr.puts "starting to create distribution"
    distribution = DCATDistribution.new(
        serverURL: server,
        baseURI: baseURI,
        title: hash['dist_title'],
        description: hash['dist_description'],
        hasVersion: hash['dist_hasVersion'],
        issued: hash['dist_issued'],
        modified: hash['dist_modified'],
        publisher: hash['dist_publisher'],
        creator: hash['dist_creator'],
        creatorName: hash['dist_creatorName'],
        contactName: hash['dist_contactName'],
        contactEmail: hash['dist_contactEmail'],
        conformsTo: hash['dist_conformsTo'],
        license: hash['dist_license'],
        accessRights: hash[' dist_accessRights'],
        dist_downloadURL: hash['dist_downloadURL'],
        mediaType: hash['dist_mediaType'],
        format: hash['dist_format'],
        parentURI: parentURI
    )

end
dataset.distribution= distribution.identifier.to_s
dataset.write_dataset


catalog.publish
dataset.publish
distribution.publish