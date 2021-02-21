resource "aws_codepipeline" "weedchart_codepipeline" {
  name     = "weedchart-pipeline"
  role_arn = aws_iam_role.weedchart_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.weedchart_codepipeline_bucket.bucket
    type     = "S3"

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
        ProjectName = "test"
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
        "s3:PutObjectAcl",
        "codestar-connections:UseConnection"
      ],
      "Resource": [
        "${aws_s3_bucket.weedchart_codepipeline_bucket.arn}",
        "${aws_s3_bucket.weedchart_codepipeline_bucket.arn}/*",
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
