#ifndef _PROCESS_H_
#define _PROCESS_H_

#include "trap.h"
#include "lib.h"

struct Process {
	struct List *next;
    int pid;
	int state;
	uint64_t context;
	uint64_t page_map;	
	uint64_t stack;
	struct TrapFrame *tf;
};

struct TSS {
    uint32_t res0;
    uint64_t rsp0;
    uint64_t rsp1;
    uint64_t rsp2;
	uint64_t res1;
	uint64_t ist1;
	uint64_t ist2;
	uint64_t ist3;
	uint64_t ist4;
	uint64_t ist5;
	uint64_t ist6;
	uint64_t ist7;
	uint64_t res2;
	uint16_t res3;
	uint16_t iopb;
} __attribute__((packed));

struct ProcessControl {
	struct Process *current_process;
	struct HeadList ready_list;
};

#define STACK_SIZE (2*1024*1024)
#define NUM_PROC 10
#define PROC_UNUSED 0
#define PROC_INIT 1
#define PROC_RUNNING 2
#define PROC_READY 3

void init_process(void);
void launch(void);
void pstart(struct TrapFrame *tf);
void yield(void);
void swap(uint64_t *prev, uint64_t next);

#endif