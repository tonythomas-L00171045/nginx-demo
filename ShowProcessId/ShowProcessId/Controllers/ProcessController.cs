using Microsoft.AspNetCore.Mvc;

namespace ShowProcessId.Controllers
{
    [ApiController]
    [Route("/")]
    public class ProcessController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        public ProcessController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet]
        public string Get()
        {
            var processId = _configuration["ProcessId"];
            return $"ProcessId: {processId}";
        }
    }
}