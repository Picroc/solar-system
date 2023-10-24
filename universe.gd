extends Node

var gravitationalConstant: float = 1000
var universeBodies: Array[CelestialBody] = []

func add_universe_body(body: Node3D):
	universeBodies.append(body)
	
func get_all_bodies():
	return universeBodies
