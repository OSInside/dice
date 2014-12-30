#include <rice/Class.hpp>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <fcntl.h>

using namespace Rice;

union semun {
  int val;
  struct semid_ds *buf;
  ushort *array;
};

int rice_semget(key_t key) {
  int semflg = S_IRWXU | IPC_CREAT;
  int nsems = 1;
  int semid = semget(key, nsems, semflg);
  return semid;
}

int rice_setval(int semid, int val) {
  union semun arg;
  arg.val = val;
  int result = semctl(semid, 0, SETVAL, arg);
  return result;
}

int rice_getval(int semid) {
  union semun arg;
  arg.val = 0;
  int result = semctl(semid, 0, GETVAL, arg);
  return result;
}

int rice_remove(int semid) {
  int result = semctl(semid, 0, IPC_RMID);
  return result;
}

extern "C"

void Init_semaphore()
{
  Class rb_c = define_class("Semaphore")
    .define_method("semget", &rice_semget)
    .define_method("setval", &rice_setval)
    .define_method("remove", &rice_remove)
    .define_method("getval", &rice_getval);
}
