# @sentry/mcp-server packaged from the npm tarball.
#
# The tarball ships a prebuilt `dist/`, so there is no build step. Its
# devDependencies point at unpublished workspace packages, so they are
# stripped at build time and the vendored package-lock.json was generated
# from the stripped package.json (see ./update.sh). importNpmLock fetches
# each dependency by the integrity hash in that lock, so the closure is
# content-addressed and nothing is fetched at runtime.
#
# Update with ./update.sh [version]; it rewrites `version`, `src.hash` and
# package-lock.json.
{ lib, buildNpmPackage, fetchurl, importNpmLock, jq }:

let
  packageLock = lib.importJSON ./package-lock.json;
in
buildNpmPackage (finalAttrs: {
  pname = "sentry-mcp-server";
  inherit (packageLock.packages."") version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@sentry/mcp-server/-/mcp-server-${finalAttrs.version}.tgz";
    hash = "sha256-7cpROv5St8/12kgrZHoFcR6Sgsp869wxLObPM4bPCos=";
  };

  nativeBuildInputs = [ jq ];

  postPatch = ''
    jq 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDeps = importNpmLock {
    inherit packageLock;
    package = packageLock.packages."";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  dontNpmBuild = true;

  meta = {
    description = "Model Context Protocol server for Sentry";
    homepage = "https://github.com/getsentry/sentry-mcp";
    license = lib.licenses.fsl11Asl20;
    mainProgram = "sentry-mcp";
  };
})
