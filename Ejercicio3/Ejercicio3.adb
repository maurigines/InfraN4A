
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

   
   task type CPU_Task (ID : Integer) is
      entry Start;
   end CPU_Task;

   task body CPU_Task is
      Accumulator : Integer := 0;
   begin
      accept Start;
      if ID = 0 then
         Put_Line("Valor de memoria inicializado en 8.");
         SEMWAIT(0);
         MEM_READ(0, Accumulator);
         Accumulator := Accumulator + 13;
         MEM_WRITE(0, Accumulator);
         Put_Line("Se le sumarán: 13");
         Put_Line("CPU 0: Memoria en posición 0 actualizada a " & Integer'Image(Memory(0)));
         SEMSIGNAL(1);
      else
         
         SEMWAIT(1);
         MEM_READ(0, Accumulator);
         Accumulator := Accumulator + 27;
         MEM_WRITE(0, Accumulator);
         Put_Line("Se le sumarán: 27");
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

   Put_Line("Arrancando CPUs...");
   CPU0.Start;
   CPU1.Start;
end Infraobligatorio;
