using NUnit.Framework;

namespace ${RootNamespace}
{
    [TestFixture]
    public class ${AssemblyName}Tests
    {
        [Test]
        public void Test1()
        {
            ${AssemblyName}.Main(new []{"HelloWorld"});
            Assert.IsTrue(true);
        }
    }
}
