with Ada.Text_IO; use Ada.Text_IO;
with Ada.Synchronous_Task_Control;

procedure Infraobligatorio is

   type Memory_Type is array (0 .. 127) of Integer;
   Memory : Memory_Type := (others => 0);

   type Semaphore_Array is array (0 .. 15) of Ada.Synchronous_Task_Control.Suspension_Object;
   Semaphores : Semaphore_Array;

   procedure SEMINIT(Sem : Integer; Value : Integer) is
   begin
      for Index in 1 .. Value loop
         Ada.Synchronous_Task_Control.Set_True(Semaphores(Sem));
      end loop;
   end SEMINIT;

   procedure BRCPU(Target_CPU : Integer; Current_CPU : Integer; IP : in out Integer) is
   begin
      if Current_CPU = Target_CPU then
         IP := IP + 1; -- Si la CPU actual coincide con la de destino, salta la instrucción
         Put_Line("BRCPU: CPU actual coincide con CPU destino. Incrementando IP a " & Integer'Image(IP));
      else
      Put_Line("BRCPU: CPU actual no coincide. No se modifica IP.");
   end if;
   end BRCPU;

   procedure SEMWAIT(Sem : Integer) is
   begin
      Ada.Synchronous_Task_Control.Suspend_Until_True(Semaphores(Sem));
   end SEMWAIT;

   procedure SEMSIGNAL(Sem : Integer) is
   begin
      Ada.Synchronous_Task_Control.Set_True(Semaphores(Sem));
   end SEMSIGNAL;

   procedure MEM_WRITE(Posicion : Integer; Valor : Integer) is
   begin
      Memory(Posicion) := Valor;
   end MEM_WRITE;

   procedure MEM_READ(Posicion : Integer; Valor : out Integer) is
   begin
      Valor := Memory(Posicion);
   end MEM_READ;

   procedure LOAD(Posicion : Integer; Acumulador : in out Integer) is
   begin
      MEM_READ(Posicion, Acumulador);
      Put_Line("LOAD: Acumulador cargado con el valor en dirección " & Integer'Image(Posicion));
   end LOAD;

   procedure STORE(Posicion : Integer; Acumulador : Integer) is
   begin
      MEM_WRITE(Posicion, Acumulador);
      Put_Line("STORE: Valor del acumulador guardado en dirección " & Integer'Image(Posicion));
   end STORE;

   procedure ADD(Posicion : Integer; Acumulador : in out Integer) is
      Valor : Integer := 0;
   begin
      MEM_READ(Posicion, Valor);
      Acumulador := Acumulador + Valor;
      Put_Line("ADD: Valor en dirección " & Integer'Image(Posicion) & " sumado al acumulador.");
   end ADD;

   task type CPU_Task (ID : Integer) is
      entry Start;
   end CPU_Task;

   task body CPU_Task is
      Acumulador : Integer := 0;
   begin
      accept Start;
      if ID = 0 then
         Put_Line("La memoria en la posición 0 se inicializa con el valor: 8");
         SEMWAIT(0);
         LOAD(0, Acumulador);
         Put_Line("CPU 0: Inicia con el valor en memoria: " & Integer'Image(Acumulador));
         ADD(1, Acumulador);
         STORE(0, Acumulador);
         Put_Line("CPU 0: Memoria en posición 0 actualizada a " & Integer'Image(Memory(0)));
         SEMSIGNAL(1);
      else
         SEMWAIT(1);
         LOAD(0, Acumulador);
         Put_Line("CPU 1: Inicia con el valor en memoria: " & Integer'Image(Acumulador));
         ADD(2, Acumulador);
         STORE(0, Acumulador);
         Put_Line("CPU 1: Memoria en posición 0 actualizada a " & Integer'Image(Memory(0)));
         Put_Line("Resultado final de valor en memoria: " & Integer'Image(Memory(0)));
      end if;
   end CPU_Task;

   CPU0 : CPU_Task (0);
   CPU1 : CPU_Task (1);

begin
   Put_Line("Inicializando memoria y semáforos...");
   SEMINIT(0, 1);
   SEMINIT(1, 0);
   MEM_WRITE(0, 8);
   MEM_WRITE(1, 13);
   MEM_WRITE(2, 27);

   Put_Line("Arrancando CPUs...");
   CPU0.Start;
   CPU1.Start;
end Infraobligatorio;
