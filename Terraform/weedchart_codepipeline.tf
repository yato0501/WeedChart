resource "aws_codepipeline" "weedchart_codepipeline" {
  name     = "weedchart-pipeline"
  role_arn = aws_iam_role.weedchart_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.weedchart_codepipeline_bucket.bucket
    type     = "S3"

##### don't fully understand what this does?
    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.weedchart_codestarconnection.arn
        FullRepositoryId = "yato0501/WeedChart"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "WeedChart"
      }
    }
  }

  # stage {
  #   name = "Deploy"

  #   action {
  #     name            = "Deploy"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "CloudFormation"
  #     input_artifacts = ["build_output"]
  #     version         = "1"

  #     configuration = {
  #       ActionMode     = "REPLACE_ON_FAILURE"
  #       Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
  #       OutputFileName = "CreateStackOutput.json"
  #       StackName      = "MyStack"
  #       TemplatePath   = "build_output::sam-templated.yaml"
  #     }
  #   }
  # }
}

resource "aws_codestarconnections_connection" "weedchart_codestarconnection" {
  name          = "weedchart-github-connection"
  provider_type = "GitHub"
}

#############################################################


resource "aws_codebuild_project" "weedchart_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "WeedChart"
  queued_timeout = 480
  service_role   = aws_iam_role.weedchart_codebuild_service_role.arn
  description = "Building the spa"

  artifacts {
    encryption_disabled    = false
    name                   = "weedchart-build"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
   # buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = true
    type                = "CODEPIPELINE"
  }
}

##################################################


resource "aws_s3_bucket" "weedchart_codepipeline_bucket" {
  bucket = "weedchart-codepipeline-bucket"
  acl    = "private"
}






resource "aws_iam_role" "weedchart_codepipeline_role" {
  name = "weedchart-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "weedchart_codebuild_service_role" {
name = "weedchart-codebuild-service-role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# resource "aws_cloudwatch_log_group" "weedchart_codebuild" {
#   name = "weedchart-codebuild"
#   role_arn = aws_iam_role.weedchart_codebuild_service_role.role.arn
# }

resource "aws_iam_role_policy" "weedchart_codebuild_service_role_policy" {
  name = "weedchart-codebuild-service-role-policy"
  role = aws_iam_role.weedchart_codebuild_service_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "weedchart_codepipeline_policy" {
  name = "weedchart-codepipeline-policy"
  role = aws_iam_role.weedchart_codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.weedchart_codepipeline_bucket.arn}",
        "${aws_s3_bucket.weedchart_codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": [
        "${aws_codestarconnections_connection.weedchart_codestarconnection.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# data "aws_kms_alias" "s3kmskey" {
#   name = "alias/myKmsKey"
# }
