git checkout --orphan chrome-build
    #eslint-disable-next-line no-console
echo "Building started..."
npm run build
    #Understand if it's dist or build folder
    git --work-tree dist/ add --all
    git --work-tree dist/ commit -m chrome-build
    # openssl genrsa -out privkey.pem 768
    # openssl pkcs8 -topk8 -nocrypt -in privkey.pem -out privkey2.pem
    chrome --pack-extension=dist \
             --pack-extension-key=dist.pem

    git checkout -f main
    git branch -D chrome-build
    echo "Successfully packaged, check your settings"
