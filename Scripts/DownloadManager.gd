extends Node
var HttpsRequestDictionary:Dictionary={}
var HttpsRequestDictionaryProgress:Dictionary={}
var CompletedRequests=[]
var identifier=0
func _get_game_zip(link,FileLocation,Version,IsClearFile):
	var HttpRequest=HTTPRequest.new()
	HttpsRequestDictionary[identifier] = HttpRequest
	HttpsRequestDictionaryProgress[identifier] = 0
	add_child(HttpRequest)
	var DownloadDir=FileLocation+"/"+link.get_file()
	HttpRequest.connect("request_completed",self,"_receive_game_zip",[identifier,DownloadDir,Version])
	HttpRequest.set_download_file(DownloadDir)
	var error=HttpRequest.request(link)
	if error!=OK:
		print("Error Request Game Files: "+str(error))
	if IsClearFile:
		_remove_all_gamefiles(FileLocation)
	print("Download Manager Request Download Initiated ID: "+str(identifier))
	identifier+=1
	return identifier-1
func _receive_game_zip(result, _response_code, _headers, _body, id, FileLocation, Version):
	remove_child(HttpsRequestDictionary[id])
	HttpsRequestDictionary.erase(id)
	HttpsRequestDictionaryProgress.erase(id)
	if result==0:#If succesfull
		#Unzip Game
		unzip(FileLocation,FileLocation.get_base_dir()+"/")
		#Create Version number
		var file = File.new()
		file.open(FileLocation.get_base_dir()+"/Version.txt", File.WRITE)
		file.store_string(Version)
		file.close()
	CompletedRequests.push_back(id)
	print("Download Manager Completed ID: "+str(id))

#Track progress
func _process(delta):
	for id in HttpsRequestDictionary:
		var HttpReq=HttpsRequestDictionary[id]
		var bodySize:float = HttpReq.get_body_size()
		var downloadedBytes:float = HttpReq.get_downloaded_bytes()
		var Progress = downloadedBytes/bodySize
		HttpsRequestDictionaryProgress[id]=Progress
func _IsSatisfiedWithDownload(id):
	CompletedRequests.remove(CompletedRequests.find(id))

#Functions
func unzip(sourceFile,destination):
	var zip_file = sourceFile
	var storage_path = destination
	
	var gdunzip = load('res://addons/gdunzip.gd').new()
	var loaded = gdunzip.load(zip_file)

	if !loaded:
		print('- Failed loading zip file')
		return false
	ProjectSettings.load_resource_pack(zip_file)
	
	for f in gdunzip.files:
		var readFile = File.new()
		if readFile.file_exists("res://"+f):
			readFile.open(("res://"+f), File.READ)
			var content = readFile.get_buffer(readFile.get_len())
			readFile.close()
			
			var base_dir = storage_path + f.get_base_dir()
			
			var dir = Directory.new()
			dir.make_dir(base_dir)
			
			var writeFile = File.new()
			writeFile.open(storage_path + f, File.WRITE)
			writeFile.store_buffer(content)
			writeFile.close()
func _remove_all_gamefiles(FileLocation):
	#Remove all files
	var dir=Directory.new()
	dir.open(FileLocation)
	dir.list_dir_begin()
	while true:
		var f=dir.get_next()
		if f == "":
			break;
		elif not f.begins_with("."):
			dir.remove(FileLocation+"/"+f)
	dir.list_dir_end()
