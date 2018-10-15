NAME	=	boilerplate.nes

SRC		=	main.asm

CA65	=	ca65

LD65	=	ld65

OBJ	=	$(SRC:.asm=.o)

PWD	= $(shell pwd)

DOCKER_IMAGE	=	nesdev

all:
	$(CA65) $(SRC)
	$(LD65) $(OBJ) -o $(NAME) -t nes

clean:
	rm -rf $(NAME)

fclean: clean
	rm -rf $(OBJ)

build-docker:
	docker run -v $(PWD):/src -w /src $(DOCKER_IMAGE) make
