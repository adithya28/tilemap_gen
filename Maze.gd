extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8
var bank=load("res://Bank.tscn")
var player_prefab=load("res://Scenes/Characters/Player_pre_scene.tscn")
var player=player_prefab.instance()
var cell_walls = {Vector2(0, -2): N, Vector2(2, 0): E, 
				  Vector2(0, 2): S, Vector2(-2, 0): W}
var bank_instance = bank.instance()
var tile_size = 64  # tile size (in pixels)
var width = 24  # width of map (in tiles)
var height = 24  # height of map (in tiles)

var map_seed = 0

# fraction of walls to remove
var erase_fraction = 0.2

# get a reference to the map for convenience
onready var Map = $TileMap

func _ready():
	##$Camera2D.position=Vector2(500,300)
	##$Camera2D.zoom = Vector2(3, 3)
	##$Camera2D.position = Map.map_to_world(Vector2(width/2, height/2))
	randomize()
	if !map_seed:
		map_seed = randi()
	seed(map_seed)
	print("Seed: ", map_seed)
	tile_size = Map.cell_size
	make_maze()
	erase_walls()
	place_levels()
	player_start()
	

		
func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
func _process(delta):
		if(round(player.position.x)==bank_instance.position.x):
			get_tree().change_scene("res://Scenes/Levels/Level1.tscn")
			
func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	for x in range(0, width, 2):
		for y in range(0, height, 2):
			unvisited.	append(Vector2(x, y))
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			Map.set_cellv(current, current_walls)
			Map.set_cellv(next, next_walls)
			# insert intermediate cell
			if dir.x != 0:
				Map.set_cellv(current + dir/2, 5)
			else:
				Map.set_cellv(current + dir/2, 10)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		##	yield(get_tree(), 'idle_frame')

func erase_walls():
	# randomly remove a number of the map's walls
	for i in range(int(width * height * erase_fraction)):
		var x = int(rand_range(2, width/2 - 2)) * 2
		var y = int(rand_range(2, height/2 - 2)) * 2
		var cell = Vector2(x, y)
		var current = Vector2(0, 0)
		# pick random neighbor
		var neighbor = cell_walls.keys()[randi() % cell_walls.size()]
		# if there's a wall between them, remove it
		if Map.get_cellv(cell) & cell_walls[neighbor]:
			var walls = Map.get_cellv(cell) - cell_walls[neighbor]
			var n_walls = Map.get_cellv(cell+neighbor) - cell_walls[-neighbor]
			Map.set_cellv(cell, walls)
			Map.set_cellv(cell+neighbor, n_walls)
			# insert intermediate cell
			if neighbor.x != 0:
				Map.set_cellv(cell+neighbor/2, 5)
			else:
				Map.set_cellv(cell+neighbor/2, 10)
		#yield(get_tree(), 'idle_frame')

func place_levels():
	var house = load("res://House.tscn")
	var tree=load("res://Tree.tscn")
	var grass=load("res://Grass.tscn")
	var npc=load("res://NPC_TOWN_1.tscn")
	var tile_size = 64
	var empty_tiles=[]
	for x in range(0, width, 1):
		for y in range(0, height, 1):
			var cell = Vector2(x, y)
			var tile=Map.get_cellv(cell)
			if (x==width-1):
				bank_instance.position = Vector2(x*tile_size,y*tile_size)
				self.add_child(bank_instance)
				break
			if(tile==15):
				empty_tiles.append(Vector2(cell.x,cell.y))
	for i in range(1,empty_tiles.size()):
		randomize()
		var index=rand_range(1,empty_tiles.size()-1)
		if(int(index)%4==0):
			var house_instance = house.instance()
			house_instance.position = Vector2(empty_tiles[index].x*tile_size,empty_tiles[index].y*tile_size)
			self.add_child(house_instance)
		elif(int(index)%3==0):
			var tree_instance = tree.instance()
			tree_instance.position = Vector2(empty_tiles[index].x*tile_size,empty_tiles[index].y*tile_size)
			self.add_child(tree_instance)
		elif(int(index)%2==0):
			var npc_instance = npc.instance()
			npc_instance.position = Vector2(empty_tiles[index].x*tile_size,empty_tiles[index].y*tile_size)
			self.add_child(npc_instance)
		else:
			var grass_instance = grass.instance()
			grass_instance.position = Vector2(empty_tiles[index].x*tile_size,empty_tiles[index].y*tile_size)
			self.add_child(grass_instance)
			pass
	yield(get_tree(), 'idle_frame')

func player_start():
	player.position=Vector2(10,10)
	self.add_child(player)
	
			
			
		
	
		

	
		
	
			
    	
		
	
			
	
			
	
