// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Globalization;
using SourceGenerator.Configuration.Test.TestData;

namespace SourceGenerator.Configuration.Test;

public class IntegrationTests {


    [Fact]
    public void TestWithoutHeader() {
        var dumy = new ConfigDumy();
        dumy.Data.Add("sub-space:required-value", 10);
        var TestParsers = new TestParsers(dumy);

        Assert.Equal(5, TestParsers.SubSpace.SubValue);
        Assert.Equal(10, TestParsers.SubSpace.RequiredValue);
        Assert.Equal(8, TestParsers.SubSpace.RequiredValueWithDefault);
        Assert.Null(TestParsers.TestRootValue);


    }

}
