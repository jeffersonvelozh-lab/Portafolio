using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class NotificacionConfiguration : IEntityTypeConfiguration<Notificacion>
    {
        public void Configure(EntityTypeBuilder<Notificacion> builder)
        {
            builder.ToTable("Notificaciones");
            builder.HasKey(n => n.Id);

            builder.Property(n => n.Tipo)
                .IsRequired()
                .HasConversion<int>();

            builder.Property(n => n.Estado)
                .IsRequired()
                .HasConversion<int>();

            builder.Property(n => n.FechaCreacion)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(n => n.MensajeError)
                .HasMaxLength(500);

            builder.HasOne(n => n.Cita)
                .WithMany(c => c.Notificaciones)
                .HasForeignKey(n => n.CitaId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
