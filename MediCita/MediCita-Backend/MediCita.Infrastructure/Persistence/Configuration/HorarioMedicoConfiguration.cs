using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class HorarioMedicoConfiguration : IEntityTypeConfiguration<HorarioMedico>
    {
        public void Configure(EntityTypeBuilder<HorarioMedico> builder)
        {
            builder.ToTable("HorariosMedico");
            builder.HasKey(h => h.Id);

            builder.Property(h => h.DiaSemana)
                .IsRequired()
                .HasConversion<int>();

            builder.Property(h => h.HoraInicio)
                .IsRequired();

            builder.Property(h => h.HoraFin)
                .IsRequired();

            builder.Property(h => h.DuracionCitaMin)
                .IsRequired();

            builder.HasOne(h => h.Medico)
                .WithMany(m => m.Horarios)
                .HasForeignKey(h => h.MedicoId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
