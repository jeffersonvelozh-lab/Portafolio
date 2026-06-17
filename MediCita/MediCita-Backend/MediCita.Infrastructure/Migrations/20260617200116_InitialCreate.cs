using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MediCita.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // la DB ya existe, no se necesita crear tablas ni relaciones
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // la DB ya existe
        }
    }
}
