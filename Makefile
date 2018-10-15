NAME	=	rom_name.nes

SRC		=	main.asm

CA65	=	ca65

LD65	=	ld65

OBJ	=	$(SRC:.asm=.o)

all:
	$(CA65) $(SRC)
	$(LD65) $(OBJ) -o $(NAME) -t nes

clean:
	rm -rf $(NAME)

fclean: clean
	rm -rf $(OBJ)
