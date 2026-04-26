rf = RandomForestClassifier(
    n_estimators=400,
    random_state=42,
    n_jobs=-1,
    max_depth=None,
    min_samples_leaf=2,
    min_samples_split=10,
    max_features="sqrt",
    class_weight="balanced_subsample",
    oob_score=True
)