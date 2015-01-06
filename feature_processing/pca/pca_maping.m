function feat = pca_maping(feat, map)
feat = (bsxfun(@minus, feat, map.mean) * map.M);