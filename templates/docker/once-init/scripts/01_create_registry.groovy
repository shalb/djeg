repository.createDockerHosted('registry', 5001, 5002, 'default', true)

if (!security.securitySystem.listRoles().any { it.roleId == 'registry-managers' }) {
    privileges = ['nx-search-read','nx-repository-view-docker-registry-read','nx-repository-view-docker-registry-browse','nx-repository-view-docker-registry-add','nx-repository-view-docker-registry-edit']
    security.addRole('registry-managers', 'registry-managers', 'deployment on all repositories', privileges, [])
}

