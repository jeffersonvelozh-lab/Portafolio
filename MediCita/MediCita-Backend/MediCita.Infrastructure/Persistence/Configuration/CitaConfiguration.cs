using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class CitaConfiguration : IEntityTypeConfiguration<Cita>
    {
        public void Configure(EntityTypeBuilder<Cita> builder)
        {
            builder.ToTable("Citas");
            builder.HasKey(c => c.Id);

            builder.Property(c => c.CodigoPublico)
                .IsRequired()
                .HasDefaultValueSql("NEWSEQUENTIALID()");

            builder.Property(c => c.FechaHora)
                .IsRequired();

            builder.Property(c => c.DuracionMin)
                .IsRequired();

            builder.Property(c => c.Estado)
                .IsRequired()
                .HasConversion<int>();

            builder.Property(c => c.Motivo)
                .HasMaxLength(500);

            builder.Property(c => c.MotivoCancel)
                .HasMaxLength(500);

            builder.Property(c => c.FechaCreacion)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.HasOne(c => c.Paciente)
                .WithMany(p => p.Citas)
                .HasForeignKey(c => c.PacienteId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(c => c.Medico)
                .WithMany(m => m.Citas)
                .HasForeignKey(c => c.MedicoId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
