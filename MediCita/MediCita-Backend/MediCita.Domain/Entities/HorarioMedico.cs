namespace MediCita.Domain.Entities
{
    public class HorarioMedico
    {
        public int Id { get; set; }
        public int MedicoId { get; set; }
        public DayOfWeek DiaSemana { get; set; }
        public TimeOnly HoraInicio { get; set; }
        public TimeOnly HoraFin { get; set; }
        public int DuracionCitaMin { get; set; }

        // Navegación
        public Medico Medico { get; set; } = null!;
    }
}