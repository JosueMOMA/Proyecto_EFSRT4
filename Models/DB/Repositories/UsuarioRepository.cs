using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EducaEFRT.Models.DB.Repositories
{
    public class UsuarioRepository : IDisposable
    {
        private readonly EduControlDB _db;

        public UsuarioRepository()
        {
            _db = new EduControlDB();
        }

        public Usuario ValidarUsuario(string username, string password)
        {
            try
            {
                return _db.Usuarios
                         .AsNoTracking()
                         .FirstOrDefault(u => u.Username == username && u.Password == password);
            }
            catch (Exception ex)
            {
                // Loggear el error aquí
                throw new Exception("Error al validar usuario", ex);
            }
        }

        public void Dispose()
        {
            _db.Dispose();
        }
    }
}