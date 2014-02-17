#define	MAX_SLOT_NUM_		5

#define	SLOT_NOTHING		0
#define	SLOT_SEND		1
#define	SLOT_RECEIVE		2
#define	SLOT_SEND_AND_RECEIVE	3

//how many slot used to send control packet
#define SLOT_AS_CONTROL		2

#define TEST_ROUTE_TIMEOUT	50    //in mac-tdma.cc, I use "expire/2" to let the useless slot be clean more quickly, but if the node receive rrep, it's slot is usefull, so this timeout should be 50*3


/*struct Slot {
	int slotCondition[MAX_SLOT_NUM_];
};
*/

