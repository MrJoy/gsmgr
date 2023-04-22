module.exports = {
    extends: ['stylelint-config-standard'],
    customSyntax: 'postcss-scss',
    rules: {
        'at-rule-no-unknown': [
            true,
            {
                ignoreAtRules: [
                    'tailwind',
                    'apply',
                    'variants',
                    'responsive',
                    'screen',
                    'layer',
                ],
            },
        ],
        'no-descending-specificity': null,
        'selector-class-pattern': null,
        // TODO: Figure out why the ignore below isn't working, and restore this rule.
        'selector-pseudo-class-no-unknown': null, /* [
            true,
            {
                ignorePseudoClasses: [':local', ':global'],
            },
        ], */
    },
    ignoreFiles: [
        'node_modules/**/*',
    ],
};
