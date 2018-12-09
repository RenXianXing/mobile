mobile->server
1 lock
	"mobile,lock-scooter,SCOOTER's IMEI, USER ID"
2.unlock
	"mobile,unlock-scooter,SCOOTER's IMEI, USER ID"
3.get available scooters
	"mobile,get-all-scooters,0,USER ID"
4.get my scooter position
	"mobile,get-scooter-post,SCOOTER's IMEI"
5.get power speed mode
	"mobile,get-scooter-power-speed-mode, SCOOTER's IMEI"

server->mobile
1.lock
	"lock-scooter,0"// 0->success
2.unlock
	"unlock-scooter,0"// 0->success
3.get available scooters
	"get-scooter-pos,scooterlatitude,latitude_hemisphere,longitude,longitude_hemisphere"
4.get my scooter postion
	"get-scooter-pos,scooterlatitude,latitude_hemisphere,longitude,longitude_hemisphere"
5.get power speed mode
	"get-scooter-power-speed-mode,power,speed,mode"