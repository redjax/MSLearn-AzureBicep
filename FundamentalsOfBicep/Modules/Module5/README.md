# Module 5 - Create composable Bicep files by using modules

- [Module](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules)

> In this module, you'll create a set of Bicep modules to deploy your website and CDN. Then, you'll create a template that uses those modules together.

## Notes

### General module notes

- Generally, it's not a good practice to create a module for every resource that you deploy.
  - A good Bicep module typically defines multiple related resources.
  - However, if you have a complex resource with a lot of configuration, it might make sense to create a single module to encapsulate the complexity.
    - This approach keeps your main templates simple and uncluttered.

### Use the Bicep visualizer to graph module dependencies

After installing the Bicep extension for Visual Studio Code, you can visualize your Bicep templates/modules to show how they relate to each other.

### Nesting modules

You can nest Bicep modules, but as the module becomes more complex with more and more nested submodules, you may find managing the module(s) difficult. For complex deployments, sometimes it makes sense to use deployment pipelines to deploy multiple templates instead of creating a single template that does everything with nesting.

### Using a module in a Bicep template

You can use the `module` keyword in a template to import that module:

```bicep
module appModule 'modules/app.bicep' = {
    name: 'myApp'
    params: {
        location: location
        appServiceAppName: appServiceAppName
        environmentType: environmentType
    }
}
```

### Naming a Bicep module

When you deploy a Bicep file by using the Azure CLI or Azure PowerShell, you can optionally specify the name of the deployment. If you don't specify a name, the Azure CLI or Azure PowerShell automatically creates a deployment name for you from the file name of the template. For example, if you deploy a file named main.bicep, the default deployment name is main.

When you use modules, Bicep creates a separate deployment for every module. The name property that you specify for the module becomes the name of the deployment. When you deploy a Bicep file that contains a module, multiple deployment resources are created: one for the parent template and one for each module.

For example, suppose you create a Bicep file named main.bicep. It defines a module named myApp. When you deploy the main.bicep file, two deployments are created. The first one is named main, and it creates another deployment named myApp that contains your application resources.

### Module parameters & outputs

Review the [Microsoft Learn documentation for adding params & outputs to your module](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/3-add-parameters-outputs-modules)
