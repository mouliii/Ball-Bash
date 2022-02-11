extends Node

const filePath:String = "./save_data/"
var fileName:String = "Sav.dat"

var data:Array = []

func SaveData()->void:
	var file = File.new()
	var isOpen = file.open(filePath + fileName, File.WRITE)
	if isOpen == OK:
		for i in range(0,data.size() - 1):
			file.store_8(data[i])
		#print("saved: ", data)
	else:
		push_error("error saving file, error: " + str(isOpen))
	file.close()

func LoadData()->void:
	data.clear()
	var file = File.new()
	if file.file_exists(filePath + fileName):
		var isOpen = file.open(filePath + fileName, File.READ)
		if isOpen == OK:
			for _i in range(0, 16):
				data.append(file.get_8())
			#print("loaded: ", data)
		else:
			push_error("error loading file, error: " + str(isOpen))
		file.close()
	else:
		#print("file did not exist")
		CreateSaveFile()

func CreateSaveFile()->void:
	var dir = Directory.new()
	var path = OS.get_executable_path().get_base_dir().plus_file("save_data")
	dir.make_dir(path)
	data.clear()
	for _i in range(0,16):
		data.append(0)
	SaveData()

func SaveProgress(level:int, challenge:int):
	var index:int = challenge + ( (level - 1) * 4) - 1
	#print("saveload: saved to index " + str(index))
	LoadData()
	data[index] = 1
	SaveData()
