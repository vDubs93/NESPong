ca65 src\reset.asm
ca65 src\players.asm
ca65 src\ball.asm
ca65 src\controllers.asm
ca65 src\sound.asm
ca65 src\CPUPlayer.asm
ca65 src\pong.asm



ld65 src\reset.o src\players.o src\ball.o src\controllers.o src\sound.o src\CPUPlayer.o src\pong.o -C nes.cfg -o NESPong.nes