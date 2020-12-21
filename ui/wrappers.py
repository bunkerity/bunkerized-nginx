#!/usr/bin/python3

import utils, config
import docker, os, stat, sys

def get_client() :
	endpoint = "/var/run/docker.sock"
	if not os.path.exists(endpoint) or not stat.S_ISSOCK(os.stat(endpoint).st_mode) :
		return False, "Can't connect to /var/run/docker.sock (is it mounted ?)"
	try :
		client = docker.DockerClient(base_url='unix:///var/run/docker.sock')
	except Exception as e :
		return False, "Can't instantiate DockerClient : " + str(e)
	return True, client

def get_containers(label) :
	check, client = get_client()
	if not check :
		return check, client
	try :
		containers = client.containers.list(all=True, filters={"label" : "bunkerized-nginx." + label})
	except docker.errors.APIError as e :
		return False, "Docker API error " + str(e)
	return True, containers

def get_instances() :
	return get_containers("UI")

def get_services() :
	services = []
	try :
		for root, dirs, files in os.walk("/etc/nginx") :
			for file in files :
				filepath = os.path.join(root, file)
				print(filepath, flush=True)
				if filepath.endswith("/nginx.env") :
					with open(filepath, "r") as f :
						service = {}
						for line in f.readlines() :
							name = line.split("=")[0]
							value = line.replace(name + "=", "", 1).strip()
							service[name] = value
						services.append(service)
	except Exception as e :
		return False, str(e)
	return True, services
