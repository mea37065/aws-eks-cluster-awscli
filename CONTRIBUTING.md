# Contributing to EKS Cluster Automation

Thank you for your interest in contributing to our EKS automation project! This guide will help you get started with contributing code, documentation, and ideas.

## 🤝 Ways to Contribute

### Code Contributions
- **Bug fixes**: Help resolve issues and improve stability
- **New features**: Add functionality that benefits the community
- **Performance improvements**: Optimize scripts and processes
- **Security enhancements**: Strengthen security posture
- **Documentation**: Improve guides, examples, and comments

### Community Contributions
- **Issue reporting**: Help identify bugs and improvement opportunities
- **Feature requests**: Suggest new capabilities and enhancements
- **Testing**: Validate changes in different environments
- **Discussions**: Share knowledge and help other users
- **Reviews**: Provide feedback on pull requests

## 🚀 Getting Started

### Prerequisites
- **AWS Account** with appropriate permissions
- **AWS CLI v2.0+** configured with credentials
- **kubectl v1.28+** for Kubernetes management
- **Helm v3.12+** for package management
- **Git** for version control
- **Bash/Shell** scripting knowledge

### Development Environment Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/aws-eks-cluster-awscli.git
   cd aws-eks-cluster-awscli
   ```

2. **Set up upstream remote**
   ```bash
   git remote add upstream https://github.com/mea37065/aws-eks-cluster-awscli.git
   ```

3. **Install development dependencies**
   ```bash
   # Install shellcheck for script linting
   sudo apt-get install shellcheck  # Ubuntu/Debian
   brew install shellcheck          # macOS
   
   # Install additional tools
   pip install pre-commit
   pre-commit install
   ```

4. **Verify setup**
   ```bash
   # Test basic functionality
   ./scripts/create-vpc.sh --help
   aws sts get-caller-identity
   kubectl version --client
   ```

## 📝 Development Workflow

### 1. Create a Feature Branch
```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- **Follow existing code style** and conventions
- **Add comments** for complex logic
- **Update documentation** as needed
- **Include error handling** and validation
- **Test in multiple environments** when possible

### 3. Test Your Changes
```bash
# Lint shell scripts
shellcheck scripts/*.sh

# Test basic functionality
./scripts/create-vpc.sh --dry-run
./scripts/create-eks.sh --validate

# Test cleanup procedures
./scripts/destroy-eks.sh --verify
./scripts/delete-vpc.sh --confirm
```

### 4. Commit Your Changes
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add multi-region support for EKS deployment

- Implement cross-region VPC peering
- Add Route 53 health checks for failover
- Update documentation with multi-region examples
- Include cost analysis for multi-region setup

Resolves #7"
```

### 5. Push and Create Pull Request
```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
gh pr create --title "feat: add multi-region support" --body "Description of changes..."
```

## 📋 Contribution Guidelines

### Code Style
- **Shell scripts**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Indentation**: 2 spaces for shell scripts, 4 spaces for YAML
- **Line length**: Maximum 100 characters
- **Comments**: Explain complex logic and business decisions
- **Error handling**: Always check command exit codes

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(monitoring): add Prometheus alerting rules
fix(vpc): resolve CIDR block conflict in multi-AZ setup
docs(readme): update installation instructions
```

### Pull Request Guidelines

#### Before Submitting
- [ ] Code follows project style guidelines
- [ ] Self-review of code changes completed
- [ ] Comments added for complex or unclear code
- [ ] Documentation updated for new features
- [ ] Tests added or updated as appropriate
- [ ] All existing tests pass
- [ ] No merge conflicts with main branch

#### PR Description Template
```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tested in development environment
- [ ] Tested in multiple AWS regions
- [ ] Tested cleanup procedures
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No merge conflicts
```

## 🧪 Testing Guidelines

### Manual Testing
- **Test in clean environment**: Use fresh AWS account or region
- **Test all code paths**: Success and failure scenarios
- **Verify cleanup**: Ensure all resources are properly removed
- **Cross-platform testing**: Test on different operating systems
- **Multi-region testing**: Validate in different AWS regions

### Automated Testing
- **Shellcheck**: Lint all shell scripts
- **YAML validation**: Validate CloudFormation and Kubernetes manifests
- **Integration tests**: Test complete deployment workflows
- **Security scanning**: Check for security vulnerabilities

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment details**: OS, AWS CLI version, region
2. **Reproduction steps**: Exact commands and parameters used
3. **Expected behavior**: What should have happened
4. **Actual behavior**: What actually happened
5. **Error logs**: Complete error messages and stack traces
6. **Additional context**: Any other relevant information

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml) for structured reporting.

## 💡 Feature Requests

For feature requests, please provide:

1. **Problem statement**: What problem does this solve?
2. **Proposed solution**: How should it work?
3. **Use cases**: Who would benefit and how?
4. **Implementation ideas**: Any thoughts on implementation?
5. **Alternatives considered**: Other approaches you've thought about?

Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml).

## 📚 Documentation

### Types of Documentation
- **README**: Overview and quick start guide
- **Code comments**: Inline documentation for complex logic
- **Architecture docs**: High-level system design
- **Tutorials**: Step-by-step guides for specific use cases
- **API docs**: Script parameters and usage examples

### Documentation Standards
- **Clear and concise**: Easy to understand for all skill levels
- **Up-to-date**: Keep in sync with code changes
- **Examples included**: Provide practical usage examples
- **Troubleshooting**: Include common issues and solutions

## 🏆 Recognition

We value all contributions and recognize contributors in several ways:

- **Contributors section** in README
- **Release notes** mention significant contributions
- **GitHub achievements** and contribution graphs
- **Community discussions** highlighting great contributions

## 📞 Getting Help

### Community Support
- **GitHub Discussions**: Ask questions and share ideas
- **Issues**: Report bugs and request features
- **Pull Request reviews**: Get feedback on your contributions

### Direct Contact
- **Maintainers**: [@uldyssian-sh](https://github.com/uldyssian-sh), [@mea37065](https://github.com/mea37065)
- **Community**: Join our discussions and connect with other contributors

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

**Thank you for contributing to the EKS automation community!** 🎉

Your contributions help make EKS deployment easier and more reliable for everyone.