namespace PSRule.Rules.Azure.Pipeline
{
    public sealed class TemplateSource
    {
        public readonly string TemplateFile;
        public readonly string[] ParametersFile;

        public TemplateSource(string templateFile, string[] parametersFile)
        {
            TemplateFile = templateFile;
            ParametersFile = parametersFile;
        }
    }
}
