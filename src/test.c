#include<stdint.h>

uint32_t testArray[100];

uint32_t addTwo(register uint32_t a, register uint32_t b){
	uint32_t i;
	for( i =0; i < 100; ++i){
		a += testArray[i];
	}
	return(a+b);
}