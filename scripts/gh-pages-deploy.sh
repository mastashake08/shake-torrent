git checkout --orphan gh-pages
    #eslint-disable-next-line no-console
echo "Building started..."
npm run build
    #Understand if it's dist or build folder
    git --work-tree dist/ add --all
    git --work-tree dist/ commit -m gh-pages
    echo "Pushing to gh-pages..."
    git push origin HEAD:gh-pages --force

    git checkout -f main
    git branch -D gh-pages
    echo "Successfully deployed, check your settings"
